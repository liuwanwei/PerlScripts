use strict;

my %hash;

MyPrint->("gg");

sub MyPrint()
{
	print "$_[0]\n";
	print "hahaha\n";
	return 0;
}

print "@INC\n";

exit 1;

#print "$#ARGV";

# When study 'Hard Reference'
my $arryref;

my $name="liuwanwei";
$arryref = \$name;
print $$arryref . "\n";

$arryref = \@ARGV;
print  scalar(@$arryref) . "\n";

$$arryref[0] = "liu";

print @$arryref;

exit 1;

$hash{name}[0] = "wwliu";
$hash{name}[1] = "liuwanwei";
$hash{age}  = 30;
$hash{idx}  = 0;

foreach (keys(%hash))
{
	if($_ eq "name")
	{
		print $hash{$_}[0].$hash{$_}[1]."\n";
	}
	else
	{
		print '$hash{'.$_.'}'." = ".$hash{$_}."\n";
	}
}

my %ha;
open(FH, "<data.dat") or die "error";

while(<FH>)
{
	next unless s/^(.*)\:\s*//;

	$ha{$1} = [split];
}

#print "ha ... $#ha";
print scalar(keys(%ha)) . "\n";

foreach (keys(%ha))
{
	print $#{$ha{$_}} . "|";
	print scalar($ha{$_}) ."\n";
	for my $i (0 .. $#{$ha{$_}})
	{
		print "$ha{$_}[$i]" . "\n";
	}

	next;

	foreach my $val ($ha{$_})
	{
		print $val."\n";
	}
}

close(FH);
