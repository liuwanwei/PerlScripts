use strict;
use Win32::Registry;
use Win32::Process;
use Win32::Process::List;

=head
	一些通用函数的定义，包括：
	1，GetDefaultExplorerDir：获取默认web浏览器的安装位置，作为打开“注册”页面的工具；
	2，GetWebsiteReverseIP：根据公司网站域名，反向解析并获得网站服务器的ip地址，作为mysql服务器地址；
=cut

# 从注册表中查找默认浏览器的安装位置
sub GetDefaultIExplorerDir()
{
	# 这个位置不可靠
	# my $Register = "Software\\Classes\\http\\shell\\open\\command";

	# 这个位置才可靠
	my $Register = "HTTP\\shell\\open\\command";
	my ($hkey, @key_list, $key, %values);

	# $HKEY_CURRENT_USER->Open($Register, $hkey) || die $!;
	$HKEY_CLASSES_ROOT->Open($Register, $hkey) || die "打开注册表键值失败！" . $@;

	$hkey->GetValues(\%values);

	my $default_dir;
	foreach (keys(%values))
	{
		# The hash's root element name is the first field name of the record.

		#print "Values: $_, name: $values{$_}[0], type: $values{$_}[1], data: $values{$_}[2]";

		# default key name is NULL
		if( $_ eq "" )
		{
			$default_dir = $values{$_}[2];
			last;
		}
	}

	$hkey->Close();

	return $default_dir;
}

sub GetWebsiteReverseIP()
{
	my $website = "www.sungeo.cn";
}

# 根据指定的名称，杀死进程
sub KillProcess()
{
	my $name = shift;

	print $name, "\n";

	my $P = Win32::Process::List->new();

	my %PID = $P->GetProcessPid($name);

	if(%PID)
	{
		foreach (keys(%PID))
		{
			my $exitcode;

			Win32::Process::KillProcess($PID{$_}, $exitcode);
		}
	}
	else
	{
		print "进程 $name 不存在\n";
	}

	return 1;

=head2
	# 使用外部程序“qprocess.exe”来获取进程列表的方式。
	# 不足地方在于会闪出dos窗口，所以被弃用。
	my @process_lines = `qprocess.exe`;

	#while(scalar(@process_lines) > 0)
	{
		foreach my $pl (@process_lines)
		{
			# 根据进程名提取进程id
			$pl =~ m/\S+\s+\S+\s+[0-9]+\s+([0-9]+)\s+(\S+)/;
			my $pid = $1;
			my $process = $2;

			#print "$pid\n";

			if($process =~ m/$name/)
			{
				# print "kill $process with PID $pid\n";

				#kill 0 => $pid;
				my $exitcode;
				Win32::Process::KillProcess($pid, $exitcode);

				# 等待被杀死的进程被os释放掉。
				sleep(1);
			}
		}

		#@process_lines = `qprocess.exe`;
	}

	return 1;
=cut
}

# &KillProcess("ihouse");
#my $exp = &GetDefaultIExplorerDir();
#print "$exp\n";
1;

