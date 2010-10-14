use strict;


for(my $i = 0; $i < 10; $i ++)
{
	#print "$i";
}

############################# array ###########################

my @list = (1, 2, 3, 4, 5, 6, 7);

#print 'length(@list) = '.length(@list)."\n";
#print 'scalar(@list) = '.scalar(@list)."\n";

foreach my $ele (@list)
{
	#print $ele;
}

for(my $i = 0; $i < 100; $i ++)
{
	#print @list[$i];
}

############################# hash ###########################

my %hash;

for(my $i = 0; $i < 100; $i ++)
{
	$hash{"index_$i"}->{'Name'} = $i;
}

print 'scalar(%hash) = '.scalar(%hash)."\n";

my $keyname = "haha";
$${keyname} = "ohaha";
print $keyname;
