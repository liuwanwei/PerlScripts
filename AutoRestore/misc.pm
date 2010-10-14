use strict;
use Win32::Registry;
use Win32::Process;
use Win32::Process::List;

=head
	һЩͨ�ú����Ķ��壬������
	1��GetDefaultExplorerDir����ȡĬ��web������İ�װλ�ã���Ϊ�򿪡�ע�ᡱҳ��Ĺ��ߣ�
	2��GetWebsiteReverseIP�����ݹ�˾��վ��������������������վ��������ip��ַ����Ϊmysql��������ַ��
=cut

# ��ע����в���Ĭ��������İ�װλ��
sub GetDefaultIExplorerDir()
{
	# ���λ�ò��ɿ�
	# my $Register = "Software\\Classes\\http\\shell\\open\\command";

	# ���λ�òſɿ�
	my $Register = "HTTP\\shell\\open\\command";
	my ($hkey, @key_list, $key, %values);

	# $HKEY_CURRENT_USER->Open($Register, $hkey) || die $!;
	$HKEY_CLASSES_ROOT->Open($Register, $hkey) || die "��ע����ֵʧ�ܣ�" . $@;

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

# ����ָ�������ƣ�ɱ������
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
		print "���� $name ������\n";
	}

	return 1;

=head2
	# ʹ���ⲿ����qprocess.exe������ȡ�����б�ķ�ʽ��
	# ����ط����ڻ�����dos���ڣ����Ա����á�
	my @process_lines = `qprocess.exe`;

	#while(scalar(@process_lines) > 0)
	{
		foreach my $pl (@process_lines)
		{
			# ���ݽ�������ȡ����id
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

				# �ȴ���ɱ���Ľ��̱�os�ͷŵ���
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

