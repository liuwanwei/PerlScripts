use strict;
use IO::Socket;

sub test()
{
if ($#ARGV == -1)
{
	print "Usage: ups_emulator.exe ip\n";
	exit 1;
}

my $local_ip = $ARGV[0];

my $server = IO::Socket::INET->new(LocalPort=>5323, 
				   Proto=>"udp",
			   	   LocalAddr=>$local_ip) 
	or die "Can't create UDP server: $@";

my ($datagram, $flags);

}

# 配合雷博测试UDP接收，暂时把监听关闭
#&Listen();

my $ipaddr = "192.168.1.134";

my $response = IO::Socket::INET->new(Proto=>"udp", 
					     PeerHost=>$ipaddr,
				     	     PeerPort=>5323);

$response->send("haha");

$response->close();

=cut head1
sub Listen()
{

while($server->recv($datagram, 64, $flags))
{
	my $ipaddr = $server->peerhost;

	print "udp from $ipaddr: $datagram\n";

	my $response = IO::Socket::INET->new(Proto=>"udp", 
					     PeerHost=>$ipaddr,
				     	     PeerPort=>2353);

	if($datagram =~ /^LOWV=/)
	{
		$response->send("LVOK");
	}
	elsif($datagram =~ /^CYCLE=/)
	{
		$response->send("CLOK");
	}
	elsif($datagram =~ /^TIME=/)
	{
		$response->send("TMOK");
	}
	elsif($datagram =~ /^CUTP/)
	{
		$response->send("CPOK");
	}
	elsif($datagram =~ /^RESP/)
	{
		$response->send("RPOK");
	}
	elsif($datagram =~ /^SEARCH/)
	{
		&BroadcastMsg($ipaddr);
	}
	else
	{
		print "Unknown msg\n";
	}

	$response->close();
}

}
=cut

sub BroadcastMsg()
{
	my $peer_ip = $_[0];

	my $tcp = IO::Socket::INET->new(Proto=>'tcp',
					PeerHost=>$peer_ip,
					PeerPort=>6018);

	$tcp->connect();
	$tcp->send("UPSS=OK");

	$tcp->close();
}
