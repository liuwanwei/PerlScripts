use Cwd;

# ..............................Parameter.......................................

# Ҫɾ����Ŀ¼����ʲô
my $g_target="cvs";

# Ҫɾ���ļ�����Ŀ¼��ɾ���ļ�����δ�⣬ɾ��Ŀ¼�����Ѳ⣩
my $g_dir_or_file="dir";
#my $g_dir_or_file="file";

# ..............................................................................





# ��ýű����ڵĵ�ǰĿ¼
my $g_cur_dir = getcwd;
#print "$g_cur_dir\n";

if($g_dir_or_file eq "dir")
{
	&DeleteSubDir($g_cur_dir);
}
else 
{
	&DeleteSubFile($g_cur_dir);
}

sub DeleteSubDir()
{
	my $handle;
	my $ndir;
	my $full_dir;

	my ($dir) = @_;
	#print "$dir\n";

	opendir($handle, $dir);
	#$ndir = readdir($handle);
	#print "$ndir\n";
	#return;

	while($ndir=readdir($handle))
	{
		if(($ndir eq ".") || ($ndir eq ".."))
		{
			next;
		}

		$full_dir = $dir."/".$ndir;

		if(-d $full_dir)
		{
			#print "$full_dir\n";

			# ɾ��Ŀ��Ŀ¼
			if( lc($ndir) =~ /^$g_target$/i)
			{
				$full_dir =~ s/\//\\/g;
				print "ɾ��Ŀ¼��$full_dir\n";
				system("rmdir /s /q $full_dir");
				#last;
			}
			else
			{
				DeleteSubDir($full_dir);
			}
		}
	}
}

sub DeleteSubFile()
{
	my $handle;
	my $ndir;
	my $full_dir;

	my ($dir) = @_;

	# del ������֧�ֱ���������Ŀ¼��ɾ���Ĺ���
	chdir($dir);
	system("del /s /q /f $g_target");
	return; # �����ﺯ���Ѿ�����


	opendir($handle, $dir);

	while($ndir=readdir($handle))
	{
		if(($ndir eq ".") || ($ndir eq ".."))
		{
			next;
		}

		$full_dir = $dir."/".$ndir;

		if(-e $full_dir)
		{
			# ɾ��Ŀ���ļ�
			if( lc($ndir) =~ /^$g_target$/i)
			{
				$full_dir =~ s/\//\\/g;
				print "ɾ��Ŀ¼��$full_dir\n";
				system("del /s /q $full_dir");
				#last;
			}
			else
			{
				DeleteSubDir($full_dir);
			}
		}
	}
}
