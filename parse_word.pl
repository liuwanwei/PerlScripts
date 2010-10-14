use Win32::OLE qw(in with);
use strict;

my $VERSION = "2009/07/08";
my $usage = "Usage of Ver: $VERSION: perl ". __FILE__ . " /abstract/path/to/word.doc(x)\n";


#print "haha". %ARGV;

#if (!%ARGV)
#{
#printf $usage;

#exit 1;

#}



my $File = $ARGV[0];

my $FileLog = $File . ".txt";

my $Word = Win32::OLE->new('Word.Application', 'Quit') or die "Couldn't run Word";

if (!$Word->Documents){

print "Word->Documents is unavailable.\n";

exit 1;

}



my $Doc = $Word->Documents->Open($File) or die "Cannot open file: $File.\n";

my ($object, $paragraph, $enum);



# the whold contents of this Office Word file (*.doc(x))

my @paras = ();



$enum = Win32::OLE::Enum->new($Doc->Paragraphs);



while(($object = $enum->Next)) {

$paragraph = $object->Range->{Text};

if (length($paragraph) < 2){

next;

}

chomp($paragraph);

$paragraph =~ s/\s//g;

$paragraph =~ s/

+$//g;



push(@paras, $paragraph);

}



$Doc->Close;

my $paras_count = @paras;

if($paras_count){

open FILELOG, ">$FileLog" or die "Cannot open log file: $FileLog\n";

foreach my $para (@paras){

print FILELOG $para, "\n";

}

close FILELOG;

print "$File has been textlized to file $FileLog.\n";

}else{

print "Sorry buddy, I tried hard but still can not parse this ms office word file.\n";

print "But I records the text in to ", $FileLog, " for your reference.\n";

}



exit 0;

