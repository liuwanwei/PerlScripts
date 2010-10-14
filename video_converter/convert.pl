use strict;
use Win32::GUI;

my ($src_dir, $dst_dir);
my ($mainwin, $textfield_src, $textfield_dst, $button_src, $button_dst, $button_start);


&ShowMainwin();

sub ShowMainwin()
{
	$mainwin = Win32::GUI::Window->new(-name => "Mainwin",
					-pos => [500, 500],
					-size=> [500, 400],
					-dialogui => 1,
					-caption => "�Զ���flvת����ipod MP4��ʽ����");

	$textfield_src = $mainwin->AddTextfield(-pos => [100, 100],
					-size => [200, 30],
					-tabstop => 1);
	$button_src = $mainwin->AddButton(-pos => [320, 100],
					-size => [100, 30],
					-tabstop => 1,
					-text => "ѡ��flv����Ŀ¼",
					-name => "BtnSrc");

	$textfield_dst = $mainwin->AddTextfield(-pos => [100, 150],
					-size => [200, 30],
					-tabstop => 1);
	$button_dst = $mainwin->AddButton(-pos => [320, 150],
					-size => [100, 30],
					-tabstop => 1,
					-text => "ѡ�����Ŀ¼",
					-name => "BtnDst");

	$button_start = $mainwin->AddButton(-pos => [170, 220],
					-size => [80, 30],
					-name => "BtnStart",
					-text => "��ʼת��");

	$button_src->SetFocus();
	$mainwin->Show();

	Win32::GUI::Dialog();
}

sub BtnSrc_Click()
{
	Win32::GUI::GetOpenFileName(-owner => $mainwin,
					-title => "haha");
} 

sub BtnDst_Click()
{
}

sub BeginConvert()
{
	my $handle;

	opendir($handle, $src_dir) or die "Can't open dir $src_dir: $!";

	# ͳ�������ԡ�.flv��Ϊ��׺���ļ�������д��̫nb�ˡ�
	my @files = grep { /\.flv$/ && -f "$src_dir/$_" } readdir($handle);
	my $cmd;
	my $real_name;

	foreach my $file (@files)
	{
		$real_name = &GetRealVideoName($file);
		$cmd = "ffmpeg -y -i " . $file . " -s 320*240 -vcodec mpeg4 -ar 24000 -f psp -muxvb 768 " . $dst_dir . "\\" . $real_name . ".mp4";
		print $cmd, "\n";
		# system($cmd);
	}

	closedir($handle);
}

sub GetRealVideoName()
{
	my $configfile = $src_dir . "\\download.bin";

	open(FH, "<$configfile") or die "can't open $configfile : $@"; 

	while(<FH>)
	{
		$_ =~ m/^<file>[0-9]*&1&(\S*)&(\S*)&\S*<\/file>/;
		print "$1 $2 \n";
	}

	close(FH);
}

1;
