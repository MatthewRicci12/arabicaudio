use strict;
use warnings;
use Readonly;
use Encode;
use LWP::UserAgent;
use URI::Encode;
use Carp::Assert;
# So the arabic characters show up on the console.
use Win32 qw();
use open ':std', ':encoding(cp'.Win32::GetConsoleOutputCP().')';
use open ':std', ':encoding(UTF-8)';


# URL prefix/suffix for the URLS I will be constructing, from the site that contains
# my data.
Readonly my $URL_PREFIX => 'https://eu.lisaanmasry.org/online/search.php?language=EG&key=';
Readonly my $URL_SUFFIX => '&action=s';
Readonly my $SOUND_URL =>  'https://www.lisaanmasry.org/php/auto/getsound.php?language=ar&sound_id=';
# What I use to communicate with the web: a UserAgent object.
my $ua = LWP::UserAgent->new();
my $encoder = URI::Encode->new({encode_reserved => 1});

 

=for comment
I believe I'm given a percent URI encoded string.
=cut
sub convToHex {
    my $bytes = shift;
    my $retVal = "%" . sprintf("%vX", $bytes);
    $retVal =~ s/\./%/g;
    return $retVal;
}

=for comment
Make a custom regex for a word, to search in a messy HTML response. As a clear
example, consider if the word is made up of the consonants in Arabic HKR. Then
the regex would be: \w*H\w*K\w*R. This is necessary because of something called
"Harakaat" in the Arabic script. They are small vowel diacritics that are used
in special circumstances. They are a nuisance for my project, however, so I am
ONLY interested in how it's written without the Harakaat, hence the \w will 
make sure the base word is matched.

PARAMETERS
$word, an Arabic word, for which I will construct a regex for. The response I
get back is basically pure HTML, so it's VERY messy. This will search for the
word amidst the chaos.

RETURNS
A regex, that can be used to grab the main consonants of a word amidst the 
Harakaat.
=cut
sub getWordRegex {
    my $word = shift;
    my $regex = substr($word, 0, 1);
    foreach (1..(length($word)-1)) {
        $regex .= "\\w*" . substr($word, $_, 1);
    }
    return $regex;
}

=for comment
Build a regex, that will look for: the word we want, followed by some number of
HTML symbols, until we come across the string "playFormDoubleClick(this, ", 
where after that, whatever number of integers we match will be the word's sound
ID. Return this.

PARAMETERS
$decodedContent, a big, ugly HTML string as a response for the get request.
$match, the regex-matched word we are looking for.

RETURN
The sound ID for the given HTML response and word.
=cut
sub getSoundID {
    my($decodedContent, $match) = @_;
    my $htmlSymbols = '\w<>/\'-:=\n; ';
    my $regex = qr/$match\S[$htmlSymbols]*playFormDoubleClick\(this, (\d+)/o;

    $decodedContent =~ $regex;
    return $1;
}

=for comment

1. Open my Arabic words file.
2. For each Arabic word, convert it to a percent URI format, so I can use it in
   a URL. ($asPercentURI)
3. Use this to construct the URL I will be sending the HTTP request to. ($url)
4. Use my UserAgent to do a get request with this URL, decode what I get back.
5. Match the word, filter it, amidst the Harakaat, by generating a per-word 
   regex. See subroutine "getWordRegex". If I've made a match, I will use this
   match as a parameter to getSoundID, and get the soundID for that word, to be
   put in $soundID.
6. Using this sound ID, make another GET request. To a file, I will print the
   raw content, which will correspond to the raw bytes of an MP3. This file is
   the MP3 file for my word. Bingo!

=cut
my $inFile = "arabicWords.txt";
open INFILE, $inFile;
while (<INFILE>) {
  chomp($_);
  my $asPercentURI = $encoder->encode($_);

  my $url = $URL_PREFIX . $asPercentURI . $URL_SUFFIX;

  my $response = $ua->get($url);
  my $decodedContent = $response->decoded_content;
  my $soundID = '';
  if ($response->is_success) {
      my $regex = getWordRegex($_);
      if ($decodedContent =~ /$regex/og) {
          $soundID = getSoundID($decodedContent, $&);
      };
  } else {
      die $response->status_line;
  }

  assert(!($soundID eq ''));
  my $file = "AudioFiles/test.mp3";
  open FILE, '>:raw', $file;
  #I got the sound ID, bitches!
  $response = $ua->get($SOUND_URL . $soundID, 'Range' => 'bytes=0-');
  my $content = $response->content;
  my $decoded_content = $response->decoded_content;
  if ($response->is_success) {
      print FILE $content;
  } else {
      die $response->status_line;
  }

  last;
}
close INFILE;
close FILE;