use warnings;
use strict;

use Win32::OLE;

my $word = CreateObject Win32::OLE 'Word.Application' or die $!;
$word->{'visible'} = 1;

my $document = $word->Documents->Add;

my $selection = $word->Selection;

$selection->TypeText("Hello World");
$selection->TypeParagraph;
