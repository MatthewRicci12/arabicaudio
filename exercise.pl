use strict;
use warnings;
use JSON;
use LWP::UserAgent ();
#print $&, "\n";
my $HOSTNAME = "http://127.0.0.1:8765/";

my $ua = LWP::UserAgent->new();
my $response = $ua->get($HOSTNAME);
if ($response->is_success) {
    print $response->decoded_content;
} else {
    die $response->status_line;
}