use strict;
use warnings;
use JSON;
use Readonly;
use LWP::UserAgent;
use Tie::IxHash;
use Data::Dumper;

Readonly my $HOSTNAME => "http://127.0.0.1:8765/";
Readonly my $DECK_NAME => "deck:current";
Readonly my $ACTION_STR => "action";
Readonly my $VERSION_STR => "version";
Readonly my $VERSION_NUM => 6;
Readonly my $PARAMS_STR => "params";
my $ua = LWP::UserAgent->new();
my $JSON = JSON->new->allow_nonref;
my $arabicRegex = getArabicRegex();

=for comment
Build the regular expression, that looks for if the charcter is a pure Arabic
word, made of Arabic characters. This is cause in the beginning of my making of
the flashcard deck, sometimes I'd transcribe the Arabic words using the Latin
alphabet, so this will ensure that I only get Arabic words.

In Unicode, the base Arabic alphabet starts from 0x601 to 0x6FF. Therefore, 
using \x{unicode}, I can match for one or more of any of these. The regex will
look something like [\x{(arabic characters)}]+.

RETURNS
A regular expression that matches words constructed of ONLY Arabic letters.
=cut
sub getArabicRegex {
    my $arabicRegex = '[';
    foreach (0x601..0x6FF) {
        $arabicRegex .= '\x{' . sprintf("%X", $_) . '}';
    }
    $arabicRegex .= ']+';
    return $arabicRegex;
}

=for comment
Creates the anki API findCards request and returns the JSON object. See 
subroutine header comment for cardsInfo for details of how this works. This
subroutine differs mainly in that the action becomes "findCards", and also this
function is hardcoded and takes no parameters. The call to findCards is not
included yet, because I want to work on a small batch of cards for now. LATER,
this will retrieve EVERY card in the deck.

RETURNS
A JSON object, which I can use to get the card IDs of all my cards.
=cut
sub findCards {
  my $ACTION = "findCards";
  my $PARAM_FIELD = "query";
  my %queryHash = ($PARAM_FIELD,$DECK_NAME);

  tie my %request, 'Tie::IxHash';
  %request = (
    $ACTION_STR => $ACTION,
    $VERSION_STR => $VERSION_NUM,
    $PARAMS_STR => \%queryHash,
  );
  my $requestAsJSON = $JSON->encode(\%request);
  return $requestAsJSON;
}

=for comment
Creates the anki API cardsInfo request and returns the JSON string thereof.
1. Specify the action I want as per the anki API documentation. "cardsInfo" in
   this case.
2. The anki API works, by taking in JSON files. I am going to start with a Perl
   Hash object. This request will map action to "cardInfo", version to 6, and
   the parameters will be the query hash, (cardsInfo->cardIds). FOR NOW, I've 
   hardcoded the array of card IDs, but in the final version, I will get ALL of
   the IDs also using the API.
3. I use my global JSON object to turn this hash into JSON and return it.

PARAMETERS
@cardIds = An array of card IDs in the deck.

RETURNS
A JSON object, in the format of the anki API, so that I may grab card info, for
each card ID I've specified (hardcoded for now).
=cut
sub cardsInfo {
  my @cardIds = shift;

  my $ACTION = "cardsInfo";
  my $PARAM_FIELD = "cards";
  my %queryHash = ($PARAM_FIELD,@cardIds);

  tie my %request, 'Tie::IxHash';
  %request = (
    $ACTION_STR => $ACTION,
    $VERSION_STR => $VERSION_NUM,
    $PARAMS_STR => \%queryHash,
  );
  my $requestAsJSON = $JSON->encode(\%request);
  return $requestAsJSON;
}

=for comment
This method takes ANY JSON object, and posts the request to the anki API, and 
will return what it returns back (a JSON object) as a Hash. 

PARAMTERS$JSONRequest, a JSON object encoded by the JSON library.

RETURNS
A JSON of the decoded content of what the Anki API returns, if everything 
went well.
=cut
sub makeRequest {
  my $JSONRequest = shift;

  my $response = $ua->post($HOSTNAME, Content => $JSONRequest);
  my $decodedContent = $response->decoded_content;
  if ($response->is_success) {
      return $decodedContent;
  } else {
      die $response->status_line;
  }
}

=for comment
START HERE
I only want to test if my code works on a very small set of card IDs for now.
This will improve performance and make debugging a lot easier. When I am
convinced that my code works, I'll run it using ALL cards, by using the anki 
API to get all card IDs.

1. Make a request to the anki API, asking for the card info of the card IDs 
   posted below. For now, these card IDs are hardcoded. Store it in $result. I
   expect $result to be a Hash or JSON object.
2. Decode the JSON object back to a hash.
3. The "result" field of the hash  contains a pointer to an array, containing
   info for my cards. @b dereferences this, and is an array OF hash pointers.
4. Open up the file of Arabic words, which for now is meant for testing. Later,
   I will get this through @b for EVERY card arbitrarily.
5. For each card information hash, get the "value" field of the "Answer" field
   in Anki.
6. If the Arabic word passes the Arabic regex, print it out. FOR DEBUGGING 
   ONLY.
=cut
my @subset = (1660318545875, 1660318614275, 1660318884050, 1660319189883, 
1660319321405, 1660319468185, 1660319595806, 1660319820974, 1660319920392, 
1660320013126, 1660320080062);
my $result = makeRequest cardsInfo \@subset;
my $ref = $JSON->decode($result);
my %resultHash = %$ref;
# NOTE: This is a reference to an array. @b is that, dereferenced.
my $a = $resultHash{'result'};
my @b = @$a;
#HASH(0x3069388) HASH(0x3878cd8) HASH(0x38790c8) HASH(0x3872480) 
#HASH(0x3872870) HASH(0x3872c60) HASH(0x3873050) HASH(0x3874488) 

#Could just literally filter it based on if it has the key 'recording'.
my $file = "./arabicWords.txt";
open FILE, ">$file" or die "$!";
foreach (@b) {
  my %cur = %$_;
  my $arabicWord = $cur{'fields'}{'Answer'}{'value'};
  if ($arabicWord =~ $arabicRegex) {
    print FILE "$&\n";
  }
}
close FILE;