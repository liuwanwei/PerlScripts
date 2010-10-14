use strict;
use Socket;


my $server = '192.168.1.217';
my $port   = '6018';
my $msg;

# 在这里修改命令
if($#ARGV == -1)
{
	print "octopus.pl -[lr]\n";
	exit 1;
}

if($ARGV[0] eq "-l")
{
	$msg = &UpsLog();
}
elsif($ARGV[0] eq "-r")
{
	$msg = &UpsSearchReply();
}
else
{
	print "octopus.pl -[lr]\n";
	exit 1;
}

my $dest = sockaddr_in($port, inet_aton($server));
my $buf = undef;

socket(SOCK, PF_INET, SOCK_STREAM, 6) or die "Can't create socket: $!";
connect(SOCK, $dest) or die "Can't connect $server:$port";

syswrite(SOCK, $msg, length($msg));

close(SOCK);

sub UpsSearchReply()
{
	return "UPSS=OK";
}

sub UpsLog()
{
	my @time = localtime();

	# generate random state field.
	my $rand = int(rand(6));

	my $sec = $time[0];
	my $min = $time[1];
	my $hour= $time[2];
	my $day = $time[3];
	my $mon = $time[4] + 1;
	my $year= $time[5] - 100;

	my $log = sprintf("UPSLOG=%02d-%02d-%02d-%02d:%02d:%02d-111.1-222.2-333.3-%d",
			$year,
			$mon,
			$day,
			$hour,
			$min,
			$sec,
			$rand);

	return $log;
}
