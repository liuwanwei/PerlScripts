use strict;
use Win32::GUI;

my $main = Win32::GUI::Window->new(
	-name	=>	"main",
	-title	=>	"test",
	-left	=>	100,
	-top	=>	100,
	-width	=>	600,
	-height	=>	400
);

my $print = $main->AddButton(
	-name	=>	'Search',
	-text	=>	'search now',
	-left	=>	25,
	-top	=>	25
);

sub Print_Click
{
	print "Searching ... ";
	#my $oldCursor = Win32::GUI::SetCursor($waitCursor);
	sleep 2;
	print "done\n";

	return 1;
}

sub Main_Terminate
{
	print "Main Window terminated\n";
	return -1;
}

$main->Show();
Win32::GUI::Dialog();

#Win32::GUI::DoEvents() >=0 or die "Window was closedduring processing";
