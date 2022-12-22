use strict;
use warnings;
use JSON;
use LWP::UserAgent ();
use Data::Dumper;
use Win32 qw( );
use URI::Encode;
use open ':std', ':encoding(cp'.Win32::GetConsoleOutputCP().')';
use open ':std', ':encoding(UTF-8)';
#use utf8;
#print $&, "\n";

sub getWordRegex {
    my $word = shift;
    my $regex = substr($word, 0, 1);
    foreach (1..(length($word)-1)) {
        $regex .= "\\w*" . substr($word, $_, 1);
    }
    return $regex;
}


my $str = "\x{0642}\x{0637}\x{0629}";
my $toMatch = "\x{0642}\x{0640}\x{064f}\x{0637}\x{0651}\x{0640}\x{064e}\x{0629}"; 
my $regex = getWordRegex $str;
if ($toMatch =~ /$regex/) {
    print "Success!\n";
}
#\x{0642}\x{0637}\x{0629}


