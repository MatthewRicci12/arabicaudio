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
  tie my %request, 'Tie::IxHash';
  %request = (
    $ACTION_STR => $ACTION,
    $VERSION_STR => $VERSION_NUM,
    $PARAMS_STR => @cardIds,
  );
  my $requestAsJSON = $JSON->encode(\%request);
  return $requestAsJSON;
}

=for comment
Takes a JSON request and runs it to AnkiConnect.
=cut
sub makeRequest {
  my $JSONRequest = shift;
  #print $JSONRequest, "\n";

  my $response = $ua->post($HOSTNAME, Content => $JSONRequest);
  my $decoded_content = $response->decoded_content;
  if ($response->is_success) {
      return $decoded_content
  } else {
      die $response->status_line;
  }
}

my $decoded_content = makeRequest findCards;
my $ref = $JSON->decode($decoded_content);
my %resultHash = %$ref;
my $cardIdArrayRef = $resultHash{'result'};
my @cardIds = @$cardIdArrayRef;


#IT'S THE RIGHT SIZE, BABY!!!

#Import card deck, that lists ALL the cards, and return whatever it returns as, likely an array. One card per index pls?
#Iterate through each card (match it with a few regexes for card type). Then if it's a certain type,
  # Take it to a certain function that is able to extract the Arabic word therein.
# With that Arabic word, we must then pass it onto http extract, and get an .ogg file back. Find a way to write it
  # in such a way that it works. Replace it in the string. Arrays are mutable, right? In which case, yea, just edit
  #that individual card.
# Finally, write it back.
#Convert arabic to hex, and back again