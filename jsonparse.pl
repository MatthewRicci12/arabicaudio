use strict;
use warnings;
use JSON::Parse 'parse_json', 'assert_valid_json';
#print $&, "\n";

# Interface with anki API and make it so each card is an element in an array.
# Take that same array and put it back into json

my $difficulty = "easy";
print "Interpolating in Perl really is as $difficulty as that!";