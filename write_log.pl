use strict;
use Win32::Registry;
use Win32;
use Win32::Process;

# 寻找winword.exe的安装位置
my $winword_path=GetWinwordPath();

( ! $winword_path eq "" )  or die "Can't find Winword.exe!";

# 根据当天日期生成日志文件名
my @time = localtime();

my $day= $time[3];
my $mon=$time[4] + 1;
my $year=$time[5] + 1900;

my $log_dir       = "d:\\log";
my $log_dir_daily = $log_dir."\\daily";
my $log_file_name = sprintf("$log_dir_daily\\liuwanwei-%d-%02d-%02d.docx", $year, $mon, $day);

if( ! -d $log_dir )
{
	system("mkdir $log_dir");
	system("mkdir $log_dir_daily");
}

# print $log_file_name;
# print "\n";

# 日志文件不存在时，从模板拷贝一份，并重命名为当天的日志文件名
if(! -e $log_file_name )
{
	my $template_file="工作日志表附件.docx";
	system("copy $log_dir\\$template_file $log_file_name");

	#print "create log file: $log_file_name";
}

sub ErrorReport()
{
	print Win32::FormatMessage(Win32::GetLastError());
}

# 使用word打开日志文件
#system('C:\\Program Files\\Microsoft Office\\Office12\\WINWORD.exe', $log_file_name);
# system($winword_path, $log_file_name);

my $word_exe_dir = $winword_path;
$word_exe_dir =~ /(^"[\w\W]*") /;
$word_exe_dir = $1;
$word_exe_dir =~ s/"/ /isg;

my $process_obj;
Win32::Process::Create( $process_obj,
			$process_obj . " " . $word_exe_dir,
			$log_file_name,
			0,
			NORMAL_PRIORITY_CLASS,
			".") or die "create $word_exe_dir $log_file_name failed : " . ErrorReport();


# -----------下面是子程序---------- #

# 从注册表中查找Winword.exe的安装位置
sub GetWinwordPath()
{
	my $Register = ".mht\\OpenWithList\\Microsoft Office Word\\shell\\edit\\command";
	my ($hkey, @key_list, $key, %values);

	$HKEY_CLASSES_ROOT->Open($Register, $hkey) || die $!;

	$hkey->GetValues(\%values);

	my $winword_dir = "";
	foreach (keys(%values))
	{
		# The hash's root element name is the first field name of the record.

		#print "Values: $_, name: $values{$_}[0], type: $values{$_}[1], data: $values{$_}[2]";

		# WINWORD.exe's default key name is NULL
		if( $_ eq "" )
		{
			$winword_dir = $values{$_}[2];
			last;
		}
	}

	$hkey->Close();

	return $winword_dir;
}
