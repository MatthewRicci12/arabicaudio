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

my $num = 0b1010001111111001;
my $length = 16;
my $result = 0;

$num = $num >> ($length - 4);
$num = $num << ($length - 4);
#print sprintf("%b", $num);

print ('' eq '');