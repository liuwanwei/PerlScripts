use strict;
use Win32::Process;
use Win32::Process::List;


my $P = Win32::Process::List->new();

my %list = $P->GetProcesses();

foreach my $key (keys(%list))
{
	#print sprintf("%30s has PID %15s\n", $list{$key}, $key);
}

#my $np = $P->GetNProcesses();
my %PID = $P->GetProcessPid("ihouse");
print keys(%PID) . "\n";

if(%PID)
{
	foreach (keys(%PID))
	{
		print "$_ has PID $PID{$_}\n";
	}
}

#print $PID. " " . $np . "\n";

#&KillProcess("ihouse");
#&KillProcess("SmartHomeServer");

sub KillProcess()
{
	my $name = shift;

	print $name, "\n";

	my $P = Win32::Process::List->new();

	my $PID = $P->GetProcessPid($name);

	if($PID)
	{
		my $exitcode;

		Win32::Process::KillProcess($PID, $exitcode);

		print "杀死进程 $name，PID $PID \n";
	}
	else
	{
		print "进程 $name 不存在\n";
	}

	return 1;
}

1;
