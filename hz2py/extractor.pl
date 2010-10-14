use strict;

my $unihan_file = "Unihan.txt";

my $i;

open(FH, $unihan_file) or die $!;
open(OUT, '>Mandarin.dat') or die $!;

while(<FH>)
{
	chomp;
	my ($u, $type, $value) = split(/\t/);
	next if($type ne 'kMandarin');

	$u =~ s/^U\+//isg;
	print OUT "$u\t$value\n";

	$i++;
}

close(FH);
close(OUT);

print "Totally $i is recorded";

1;
