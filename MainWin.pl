use strict;
use Win32::GUI();

=head1
	���Կؼ����ض�����������Ϣ�Ĵ�������������ѡ��Textfield��Ϊ���Զ���
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

$listview->InsertColumn(-text => "�û�",
			-align=> "left",
			-width=> 66,
			-index=> 2,
			-subitem=> 3);
$listview->InsertColumn(-text => "����",
			-align=> "left",
			-width=> 66,
			-index=> 2,
			-subitem=> 3);
$listview->InsertColumn(-text => "��ע",
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
	# ����Ϳ���֪�����а�����keycode����ȻҲ����enter��ඡ�
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

	# ��ȡenter��ʵʱ״��������ǡ�1�����ٺٺٺ�
	$state = Win32::GUI::GetKeyState(13);
	print $state . "\n";
}

# �������ղ����������µ���Ϣ������û�а취�أ�
sub MainWin_KeyDown()
{
	my $state = Win32::GUI::GetKeyState(13);
	print $state . " MainWin_KeyDown \n";
}
