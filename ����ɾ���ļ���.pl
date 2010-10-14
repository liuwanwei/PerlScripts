use Cwd;

# ..............................Parameter.......................................

# 要删除的目录名是什么
my $g_target="cvs";

# 要删除文件还是目录（删除文件功能未测，删除目录功能已测）
my $g_dir_or_file="dir";
#my $g_dir_or_file="file";

# ..............................................................................





# 获得脚本所在的当前目录
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

			# 删除目标目录
			if( lc($ndir) =~ /^$g_target$/i)
			{
				$full_dir =~ s/\//\\/g;
				print "删除目录：$full_dir\n";
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

	# del 命令本身就支持遍历所有子目录并删除的功能
	chdir($dir);
	system("del /s /q /f $g_target");
	return; # 到这里函数已经结束


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
			# 删除目标文件
			if( lc($ndir) =~ /^$g_target$/i)
			{
				$full_dir =~ s/\//\\/g;
				print "删除目录：$full_dir\n";
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
