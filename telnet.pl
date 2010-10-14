use strict;
use Win32::Job;

my $job = Win32::Job->new;

for(my $i = 0; $i < 64; $i ++)
{
	$job->spawn(undef, "telnet 192.168.1.103 7070");
}

$job->run(10);
