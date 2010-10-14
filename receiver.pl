use strict;
use IO::socket;

my $sock = new IO::Socket::INET(
	LocalHost => '192.168.1.75',
	LocalPort => '7070',
	Proto => 'tcp',
	Listen => 3,
	Reuse => 1
	);
die "Couldn't create socket: $!\n" unless $sock;


my $new_sock; 
my $pid;
my $child = 0;

while($new_sock = $sock->accept())
{
	$pid = fork();
	die "Fork child process error: $!\n" unless defined $pid;

	if(! $pid)
	{
		$child ++;
		print "one more: $child\n";
		while(<$new_sock>)
		{
			chop();

			print "$_\n";

			if($_ eq "q")
			{
				print "last";
				last;
			}
		}

		exit(0);
	}
}

close($sock);
