use strict;
use Win32::GUI();

=head1
	测试控件对特定按键按下消息的处理能力，这里选择Textfield作为测试对象
=cut

my $mainwin = Win32::GUI::Window->new(-name => "MainWin", 
				-width => 500,
				-height => 350,
				-dialogui => 1);

my $textfield = $mainwin->AddTextfield(-name => "NameInput",
				-pos => [100, 80],
				-size=> [100, 30],
				-tabstop => 1);

my $button = $mainwin->AddButton(-name => "click me",
				-pos => [100, 120],
				-size=> [100, 30],
				-tabstop => 1);

my $listview = $mainwin->AddListView(-name => "ListView",
				-pos => [100, 155],
				-size=> [200, 180],
				-sortascending=> 1,
				-singlesel=>1,
				-editlabel=>1,
				-reordercolumns=>1);

$listview->InsertColumn(-text => "用户",
			-align=> "left",
			-width=> 66,
			-index=> 2,
			-subitem=> 3);
$listview->InsertColumn(-text => "日期",
			-align=> "left",
			-width=> 66,
			-index=> 2,
			-subitem=> 3);
$listview->InsertColumn(-text => "备注",
			-align=> "left",
			-width=> 66,
			-index=> 2,
			-subitem=> 3);

$listview->InsertItem(-text => "haha",);
$listview->SetItemText(0, "2", 1);
$listview->SetItemText(0, "3", 2);

$listview->InsertItem(-text => "wawa",);
$listview->SetItemText(1, "1", 1);
$listview->SetItemText(1, "2", 2);

$textfield->SetFocus();
$mainwin->Show();
Win32::GUI::Dialog();

sub NameInput_KeyDown()
{
	# 这里就可以知道所有按键的keycode，当然也包括enter键喽。
	my $key = Win32::GUI::GetKeyboardState();

	for(my $i = 0; $i < 256; $i ++)
	{
		if($key->[$i])
		{
			print "keycode $i is down\n";
			last;
		}
	}

	my $state;

=head1
	if(Win32::GUI::GetKeyState(9))
	{
		$button->SetFocus();
	}
=cut

	# 获取enter键实时状况，如果是‘1’，嘿嘿嘿嘿
	$state = Win32::GUI::GetKeyState(13);
	print $state . "\n";
}

# 主界面收不到按键按下的消息啦，有没有办法呢？
sub MainWin_KeyDown()
{
	my $state = Win32::GUI::GetKeyState(13);
	print $state . " MainWin_KeyDown \n";
}
