use strict;
use warnings;
use Readonly;
use Encode;
use LWP::UserAgent;
use URI::Encode;
#So it shows up.
use Win32 qw();
use open ':std', ':encoding(cp'.Win32::GetConsoleOutputCP().')';
use open ':std', ':encoding(UTF-8)';


Readonly my $URL_PREFIX => 'https://eu.lisaanmasry.org/online/search.php?language=EG&key=';
Readonly my $URL_SUFFIX => '&action=s';
my $ua = LWP::UserAgent->new();
my $encoder = URI::Encode->new({encode_reserved => 1});

sub convToHex {
    my $bytes = shift;
    my $retVal = "%" . sprintf("%vX", $bytes);
    $retVal =~ s/\./%/g;
    return $retVal;
}

sub getWordRegex {
    my $word = shift;
    my $regex = substr($word, 0, 1);
    foreach (1..(length($word)-1)) {
        $regex .= "\\w*" . substr($word, $_, 1);
    }
    return $regex;
}

my $inFile = "arabicWords.txt";
open INFILE, $inFile;
while (<INFILE>) {
  #print "$_\n\n";
  chomp($_);
  my $asPercentURI = $encoder->encode($_);

  my $url = $URL_PREFIX . $asPercentURI . $URL_SUFFIX;
  #print "$url\n\n";

  my $response = $ua->get($url);
  my $decodedContent = $response->decoded_content;
  if ($response->is_success) {
      #Decoded content is result of get request.
      print $decodedContent;
      #Regex to match the word amidst the "Harakaat"
      my $regex = getWordRegex($_);
      #Extract the word with the Harakaat, store in $&.
      $decodedContent =~ /$regex/o
      #Based on decoded content and match, we should be able to find the id.
      my $soundID = getSoundId($decodedContent, $&);

  } else {
      die $response->status_line;
  }
  die;
  last;
}
close INFILE;

=for comment
1. Read file one by one of Arabic words. {'fields'}{'Answer'}{'value'}
2. Make URL.
3. GET request to that URL.
4. Read it.
=cut

# I have received an Arabic word. I am going to send an HTTP request to give me the file at the
  # address that ends in id=, and get a file string/download it. Ideally it's on my system, then I can just
  # give a link back to ankirequest.


# I have card IDs, I need to get the arabic words now.
# 1. How do Arabic words show up in a URL?



#https://eu.lisaanmasry.org/online/search.php?language=EG&key=%D9%82%D8%B9%D8%AF&action=s