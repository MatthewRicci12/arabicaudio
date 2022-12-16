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

=for comment
Creates the anki API findCards request and returns the JSON string.
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
Creates the anki API cardsInfo request and returns the JSON string.

PARAMETERS
  @cardIds = An array of card IDs in the deck.
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
Takes a JSON request and runs it to AnkiConnect.
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

#JSON result of making the findCards request.
#my $result = makeRequest findCards;
#A reference to the hash that decode returns
#my $ref = $JSON->decode($result);
#The hash dereferenced
#my %resultHash = %$ref;
#The 'result' field of the hash that holds my card IDs.
#my $cardIdArrayRef = $resultHash{'result'};
#The card IDs.
#my @cardIds = @$cardIdArrayRef;
#A smaller version so we don't get overwhelmed while debugging
#my @subset = @cardIds[0..10];

my @subset = (1660318545875, 1660318614275, 1660318884050, 1660319189883, 1660319321405, 1660319468185, 1660319595806, 1660319820974, 
1660319920392, 1660320013126, 1660320080062);
my $result = makeRequest cardsInfo \@subset;
my $ref = $JSON->decode($result);
my %resultHash = %$ref;



# my $file = "./resultHash.txt";
# open FILE, ">$file" or die "$!";
# print FILE Dumper(%resultHash);
# close FILE;


#Import card deck, that lists ALL the cards, and return whatever it returns as, likely an array. One card per index pls?
#Iterate through each card (match it with a few regexes for card type). Then if it's a certain type,
  # Take it to a certain function that is able to extract the Arabic word therein.
# With that Arabic word, we must then pass it onto http extract, and get an .ogg file back. Find a way to write it
  # in such a way that it works. Replace it in the string. Arrays are mutable, right? In which case, yea, just edit
  #that individual card.
# Finally, write it back.
#Convert arabic to hex, and back again