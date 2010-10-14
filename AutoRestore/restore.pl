BEGIN
{
	#push(@INC, "C:\\Perl\\site\\lib");
	#push(@INC, "C:\\Perl\\lib");
	#push(@INC, "..\\AutoRestore");
}

use strict;
use threads ('yield',
        'stack_size' => 64*4096,
        'exit' => 'threads_only',
        'stringify');

#require "sql.pl";
#require "ftp.pl";
#require "misc.pl";

use ftp;
use misc;
use sql;

# ָ�����ڳߴ�
my ($w, $h) = qw(500, 350);
my ($btn_w, $btn_h) = qw(70, 21);

my $loginwin;
my $mainwin;

# ��¼ʹ�õ��û��������룬��¼�ɹ��������������ݡ��͡��ָ�����Ϣ������ʹ��
my ($username, $password);
# �Ƿ��¼�ɹ���1���ɹ�
my $login_ok = 0;

# �Ƿ������������ݿ�
my $logon_db = 0;

# �Ƿ����سɹ�
my $download_ok = 0;

# ��¼�����ӿؼ�
my ($label_help, $label_register, $label_input, $label_user, $tf_user, $btn_reg, $label_pass, $tf_pass, $btn_login, $sb_login);

# �������ӿؼ�
my ($radio_backup, $btn_backup, $radio_restore, $listbox_record, $btn_delete, $btn_restore, $sb_mainwin);

if($#ARGV < 0)
{
       exit(1);
}

if($ARGV[0] ne "-xg")
{
       exit(1);
}

#�ж������ļ����Ƿ���ftp��������mysql����������Ϣ�����û�����������Ϣд�뵽SmartHomeInfo.ini��
sub CheckConfigFile()
{
         # ��ǰĿ¼
         my $cur_dir = getcwd();

         # ת����windows��ʽ����'\'����'/'
         my $abs_path = abs_path($cur_dir);

         #���������׷�ӵķ�ʽ��ʹ��>>�ķ�ʽ�����ļ������ܶ����ļ��е����ݣ�����������ͨ��ʽ��
         open(MYFILE, "$abs_path\\SmartHomeInfo.ini") or die "cannot open SmartHomeInfo.ini: $!\n";
         my @contents = <MYFILE>;
         my @mysql_server_line = grep /FtpServerIP/, @contents;
         if(!$mysql_server_line[0])
         {
                close(MYFILE);
                open(MYFILE, ">>$abs_path\\SmartHomeInfo.ini") or die "cannot open SmartHomeInfo.ini: $!\n";

                #���ļ���д������
                print MYFILE "\nFtpServerIP=192.168.1.137\n";
                print MYFILE "MysqlHost=192.168.1.137";
                close(MYFILE);
         }
}


# �����̴߳����ݿ⡣�߳��д򿪵����ݿ��������ڸ��߳��й���������ʱ�����߳�ʵ�֡�
#my $thr = threads->create('OpenDB') or die "Thread->new : $@";
# $SIG{'KILL'} = 'Main_Terminate';

&CheckConfigFile();

# ��ʾ��½����
&ShowLoginWindow();

# ��ʾ������
&ShowMainWindow();

sub ShowLoginWindow()
{
        $loginwin = Win32::GUI::Window->new(-name => "Login",
                                              -text => "���ݱ�����ָ�",
                                           -width => $w,
                                           -height => $h,
                                              -minsize => [$w, $h],
                                              -maxsize => [$w, $h],
                                           -dialogui => 1,
                                           -tabstop => 1);

        $label_help = $loginwin->AddLabel(-text => "    ����������Խ�iHouse�е�������Ϣ�ϴ����ݵ��ع⹫˾ר�÷������ϣ�Ҳ���Խ��Ѿ��ϴ����ݵ�������Ϣ�ָ������ڵ�iHouseϵͳ�С�",
                                        #-foreground => 0x0000ff,
                                            -pos => [50, 30],
                                            -size => [400, 50]);

        $label_register = $loginwin->AddLabel(-text => "��⣬�һ�û��ע�ᣡ-------------------------------------------------", -pos => [50, 80], -size => [440, 20]);

        $btn_reg = $loginwin->AddButton(-name => "BtnRegister",
                                    -text => "����ע��",
                                        -pos  => [390, 105],
                                        -size => [70, 21],
                                    -tabstop => 1,
                                        -tip=> "ע���û���Ϣ");

        $label_input = $loginwin->AddLabel(-text => "�����룺-------------------------------------------------------------", -pos => [50, 145], -size => [440, 20]);

        $label_user = $loginwin->AddLabel(-text => "�û�����",
                                   -pos => [50, 182],
                                      -size=> [50, 30]);

        $tf_user = $loginwin->AddTextfield(-pos => [107, 182],
                                       -size => [233, 23],
                                       -tabstop => 1,
                                              -tip => "�����û���");
        $tf_user->SetLimitText(32);

        $label_pass = $loginwin->AddLabel(-text => "��  �룺",
                                         -pos => [50, 215],
                                          -size => [50, 40]);

        $tf_pass = $loginwin->AddTextfield(-name => "TFPass",
                                          -pos => [107, 215],
                                          -size => [233, 23],
                                          -password => 1,
                                                 -tabstop => 1,
                                            -tip => "��������");
        $tf_pass->SetLimitText(32);


        $btn_login = $loginwin->AddButton(-name => "BtnLogin",
                                            -text => "��¼",
                                            -pos  => [390, 225],
                                            -size => [70, 21],
                                            -tabstop => 1,
                                            -tip => "��¼���ݷ�����");
        $sb_login = $loginwin->AddStatusBar();

        # �ƶ����ڵ���Ļ������

        my $desk = Win32::GUI::GetDesktopWindow();
        my $dw = Win32::GUI::Width($desk);
        my $dh = Win32::GUI::Height($desk);
        my $x  = ($dw - $w) / 2;
        my $y  = ($dh - $h) / 2;
        $loginwin->Move($x, $y);

        # ��ʾ����
        $loginwin->Show();

        # ���㼯�е��û����������
        $tf_user->SetFocus();

        # ������Ϣѭ�������򴰿ھͻ�һ������
        Win32::GUI::Dialog();
}

# ����������������Ϣ���д���
# �ж��Ƿ��¡�ENTER����������ǣ����õ�¼����
# FIXME ��window��dialogui���Ա����ó�1ʱ���ؼ����ղ���enter��Ϣ��
sub TFPass_KeyDown()
{
        my $state = Win32::GUI::GetKeyState(13);

        if($state)
        {
                &BtnLogin_Click();
        }

        # print  $state. "\n";
}

# ��ĳ������ʼ�����û����������ؼ�
sub EnableBackupGUI()
{
        my $flag = shift;

        $btn_backup->Enable($flag);
}

sub EnableRestoreGUI()
{
        my $flag = shift;

        $btn_delete->Enable($flag);
        $btn_restore->Enable($flag);
}

# ��ʾ������
sub ShowMainWindow()
{
        # ��������
        $mainwin = Win32::GUI::Window->new(-name => "Main",
                                              -text => "���ݱ�����ָ�",
                                           -width => $w,
                                           -height => $h,
                                              -minsize => [$w, $h],
                                              -maxsize => [$w, $h],
                                           -dialogui => 1,
                                           -tabstop => 1);

        $radio_backup = $mainwin->AddRadioButton(-name => "RadioBackup",
                                              -text => "��Ҫ���ݣ�-------------------------------------------------------",
                                              -pos  => [40, 24],
                                                    -size => [440, 20]);

        $btn_backup = $mainwin->AddButton(-name => "BtnBackup",
                                        -text => "��ʼ����",
                                        -pos  => [390, 55],
                                       -size => [$btn_w, $btn_h],
                                       -tabstop => 1,
                                              -tip  => "�����ܼҾ�ϵͳ��Ϣ���ݵ��ع��������");

        $radio_restore = $mainwin->AddRadioButton(-name => "RadioRestore",
                                                  -text => "��Ҫ�ָ���-------------------------------------------------------",
                                                  -pos => [40, 90],
                                                    -size => [440, 20]);

=useless
        $btn_listrecord = $mainwin->AddButton(-name => "BtnListRecord",
                                        -text => "�г����ݼ�¼",
                                         -pos  => [50, 100],
                                         -size => [$btn_w, $btn_h - 10],
                                               -tabstop => 1,
                                        -tip  => "�г��ѱ��ݵ�����");
=cut

        $listbox_record = $mainwin->AddListbox(-name => "ListboxRecord",
                                            -multicolumn => 0,
                                                -pos  => [55, 120],
                                            -size => [325, 130],
                                                   -tabstop => 1,
                                            -tip  => "���ݼ�¼");

        $listbox_record->ItemHeight(20);

        $btn_delete = $mainwin->AddButton(-name => "BtnDeleteRecord",
                                       -text => "ɾ��",
                                       -pos  => [55, 246],
                                       -size => [50, $btn_h],
                                       -tabstop => 1,
                                       -tip  => "ɾ��ѡ�еı��ݼ�¼");
        # �տ�ʼ�б��Ϊ�գ����Խ��á�ɾ������ť
        $btn_delete->Enable(0);

        $btn_restore = $mainwin->AddButton(-name => "BtnRestore",
                                        -text => "��ʼ�ָ�",
                                        -pos  => [390, 246],
                                        -size => [$btn_w, $btn_h],
                                        -tip  => "��ѡ�еļ�¼�лָ�����");
        # �տ�ʼ�б��Ϊ�գ����Խ��á���ʼ�ָ�����ť
        $btn_restore->Enable(0);

        $sb_mainwin = $mainwin->AddStatusBar();;

        # �ƶ����ڵ���Ļ������
        my $desk = Win32::GUI::GetDesktopWindow();
        my $dw = Win32::GUI::Width($desk);
        my $dh = Win32::GUI::Height($desk);
        my $x  = ($dw - $w) / 2;
        my $y  = ($dh - $h) / 2;
        $mainwin->Move($x, $y);

        # ��ʾ����
        $mainwin->Show();

        &BtnListRecord_Click();

        # Ĭ�Ͻ��롰���ݡ�������
        $radio_backup->Checked(1);
        RadioBackup_Click();

        # ������Ϣѭ�������򴰿ھͻ�һ������
        Win32::GUI::Dialog();

}

sub Main_Terminate()
{
        # print "�˳�������\n";

        # �ڻָ������һ�����ȴ��û����롰ȷ����ʱ������������⣬���������������ݻָ�
        if($download_ok)
        {
                # �������������ļ����±������ݿ�
                &RestorePCSoft() or (Win32::GUI::MessageBox(undef, "�������ݿ�ʧ�ܣ�") && &EnableRestoreGUI(1) && return 0);
        }

        &ShowStatusMsg("���ڹر����ݿ⣬���Ժ򡣡���");

        #$thr->kill('KILL');
        #$thr->join();

        &CloseDB();

        exit(0);
}

sub Login_Terminate()
{
        print "�˳���¼����\n";

        # ��¼ʧ�ܺ�ǿ���˳���¼����ʱ����Ҫ�ر����ݿ�����
        if($login_ok == 0)
        {
                &CloseDB();
        }

        exit(0);
}

# ��¼ʱ�����õ�¼��ť
sub EnableLoginWinGUI()
{
        my $flag = shift;

        $btn_login->Enable($flag);
}

# ��ע�ᡱ��ť��Ϣ������
sub BtnRegister_Click()
{
        my $iexploere = &GetDefaultIExplorerDir();

        #print "$iexploere\n";

        # �ҳ�Ĭ��������ĳ��������Ѳ���ȥ��
        # ��һ�������а��������ݾ��������exe�ľ���·����������ո�Ȼ���ǲ�����
        # ��Ҫ�Ƴ�������
        # Ŀǰ���Թ�֧��ff��ie��
        $iexploere =~ /(^"[\w\W]*") /;

        $iexploere = $1;

        #print "$iexploere\n";

        system($iexploere, "http://www.sungeo.cn/register.php");
}

# ����¼����ť��Ϣ������
sub BtnLogin_Click()
{
        # ����û����Ƿ��������Ҫ��
        if(! &PreCheckUserinfo())
        {
                return 0;
        }

        #print "$username, $password |||\n";

        $sb_login->SetText(0, "��¼�У����Ժ򡣡���");

        # ���Դ����ݿ�
        if(! &OpenDB())
        {
                &EnableLoginWinGUI(1);
                $sb_login->SetText(0, "�������ݿ�ʧ�ܣ�");
                return 0;
        }

        # ��֤�û���Ϣ�Ƿ�Ϸ�
        &ShowStatusMsg("���������û� ".$username." ����Ϣ... ");
        if(! &CheckUserinfo($username, $password))
        {
                $tf_user->SetFocus();
                &EnableLoginWinGUI(1);

                $username = "";
                $password = "";
                $sb_login->SetText(0, "");

                Win32::GUI::MessageBox(undef, "��ȷ���û���Ϣ�Ƿ���ȷ��");
                &ShowStatusMsg("");

                return 0;
        }
        else
        {
                # FIXME �˳���¼��������������
                # ����û���˳���ֻ�������ˡ�
                $loginwin->Hide();
                Win32::GUI::PostQuitMessage();

                $login_ok = 1;

                return 1;
        }

}

# ����û��������Ƿ�Ϸ�
sub PreCheckUserinfo()
{
        my $user = $tf_user->Text();
        my $pass = $tf_pass->Text();

        # print "$user, $pass\n";

        if($user eq "" or $pass eq "")
        {
                Win32::GUI::MessageBox(undef, "�û������Ϣ�������������룡");
                if($user eq "")
                {
                        $tf_user->SetFocus();
                }
                elsif($pass eq "")
                {
                        $tf_pass->SetFocus();
                }

                return 0;
        }

        # ���û���������ĺϷ�������֤
        if($user =~ / / or $pass =~ / /)
        {
                Win32::GUI::MessageBox(undef, "�û����������в����пո�");
                return 0;
        }

        $username = $user;
        $password = $pass;

        return 1;
}

sub RadioBackup_Click()
{
        $btn_backup->Enable(1);

        $btn_restore->Enable(0);
        $btn_delete->Enable(0);
        $listbox_record->Enable(0);
}

sub RadioRestore_Click()
{
        $btn_backup->Enable(0);

        $btn_restore->Enable(1);
        $btn_delete->Enable(1);
        $listbox_record->Enable(1);
}

# �����ݡ���ť��Ϣ������
sub BtnBackup_Click()
{
        # ���ÿؼ�
        &EnableBackupGUI(0);

        &IsDBOK() or return -1;

        # ��鱸�ݴ����Ƿ񳬹����ֵ����������������
        if(! &CheckBackupTimes($username))
        {
                Win32::GUI::MessageBox(undef, "�û����ݴ����Ѿ��������ֵ", "����");
                &EnableBackupGUI(1);
                return 0;
        }

        #���һ������Ϊ�˷�ֹ�û���һ�����ڲ�ֹһ�ε���˱��ݰ�ť������������ڵ��ظ�
        sleep(1);

        # ���ɵ�ǰ���ڴ�����¼���ݻ�ԭ��
        my $date;
        my @time = localtime();
        $date = sprintf("%d%02d%02d%02d%02d%02d", $time[5] + 1900, $time[4] + 1, $time[3], $time[2], $time[1], $time[0]);

        # ������������𣿿��ԣ������������ݿ��ļ����һ����
        # my $packet_path = &PackBackupPacket();

        &ShowStatusMsg("�����С�����������");

        # �����ݿⱸ�����ݱ����һ����¼������Ҫ��ʼ���룬��flag��־Ҫ��Ϊ0��������δ������ɣ���ֹftp����ʧ�����ftp��mysql���ݲ�ͬ��
        if(! &PrepareBackupRecord($username, $date))
        {
                &ShowStatusMsg("����ʧ�ܣ����Ժ��ԡ�");
        }

        # ������õı������ݴ��͵�ftp������
        if(! &UploadBackupPacket($username, $date))
        {
                &ShowStatusMsg("����ʧ�ܣ������������ӡ�");
                return;
        }

        # �������ݿⱸ�����ݱ�ļ�¼����flag��־��1������������ϣ��������ʧ�ܣ��Ǿͻ�������ݲ�ͬ����
        if(! &UpdateBackupRecord($username, $date))
        {
                &ShowStatusMsg("����ʧ�ܣ��������֧����Աȡ����ϵ��");
        }

        &EnableBackupGUI(1);

        &BtnListRecord_Click();

        &ShowStatusMsg("���ݳɹ���");

        return;
}

# ���г����ݼ�¼����ť��Ϣ������
sub BtnListRecord_Click()
{
        # ����б���оɵ�����
        $listbox_record->ResetContent();

        &IsDBOK() or return -1;

        # �����ݿ���ȡ���û����µ����б��ݼ�¼
        my @records = &QueryBackupRecord($username);

        foreach my $item (@records)
        {
                # ��ʾ���û���+�������ڡ���ʽ�ı��ݼ�¼
                $listbox_record->AddString($username . " " . $item);
        }

        return 0;
}

# ��ɾ������ť��Ϣ������
sub BtnDeleteRecord_Click()
{
        # �����ݿ�
        if(! &OpenDB())
        {
                return 0;
        }

        my $index;
        my $string;
        if(($index = $listbox_record->GetCurSel()) < 0)
        {
                Win32::GUI::MessageBox(undef, "����б����ѡ��һ������ʱ���");
                return 0;
        }

        &EnableRestoreGUI(0);

        # �б���ڱ��������ݣ������ڴ�֮ǰusername�ĺϷ����Ѿ��������飬��ʱ�����ٴμ��飬ֱ����ȡ�û����ͱ�������

        $string = $listbox_record->GetString($index);

        # ��ȡ�û����ͱ�������
        my ($username, $date) = split(/ /, $string);
        print "�����ļ���Ϣ��$username, $date \n";

        # ���ȴ�FTP��������ɾ��
        if(! &DeleteBackupPacket($username, $date))
        {
                Win32::GUI::MessageBox(undef, "���ļ�������ɾ������ʧ�ܣ�");
                &EnableRestoreGUI(1);
                return;
        }

        # ��δ�MYSQL��ɾ��
        &ShowStatusMsg("ɾ���У����Ժ򡣡���");
        &DeleteBackupRecord($username, $date) or (Win32::GUI::MessageBox(undef, "�����ݿ������ɾ������ʧ�ܣ�") && &EnableRestoreGUI(1) && return -1);
        &ShowStatusMsg("ɾ���ɹ���");


        # ���б����ɾ����ʾ
        $listbox_record->DeleteString($index);

        &ShowStatusMsg("ɾ���ɹ���");

        &EnableRestoreGUI(1);
        return 0;
}

# ����ʼ�ָ�����ť��Ϣ������
sub BtnRestore_Click()
{
        my $index;
        my $string;

        if(($index = $listbox_record->GetCurSel()) < 0)
        {
                Win32::GUI::MessageBox(undef, "����б����ѡ��һ������ʱ���");
                return 0;
        }

        if(! &OpenDB())
        {
                return 0;
        }

        &ShowStatusMsg("���ڻָ��У����Ժ򡣡���");

        &EnableRestoreGUI(0);

        # �б���ڱ��������ݣ������ڴ�֮ǰusername�ĺϷ����Ѿ��������飬��ʱ�����ٴμ��飬ֱ����ȡ�û����ͱ�������

        $string = $listbox_record->GetString($index);

        # ��ȡ�û����ͱ�������
        my ($username, $date) = split(/ /, $string);
        # print "�����ļ���Ϣ��$username, $date \n";

        # ��ftp���������ر��ݺõ��ļ�
        if(! &DownloadBackupPacket($username, $date))
        {
                Win32::GUI::MessageBox(undef, "���ر����ļ�ʧ�ܣ�");
                &ShowStatusMsg("���ر����ļ�ʧ�ܣ�");
                       &EnableRestoreGUI(1);
                return;
        }

        &ShowStatusMsg("�ļ����سɹ�����ʼ�������������");

        $download_ok = 1;

        Win32::GUI::MessageBox(undef, "�ָ��ɹ�����������iHouse", "������Ϣ���ڣ�$date");

        # �������������ļ����±������ݿ�
        &RestorePCSoft() or (Win32::GUI::MessageBox(undef, "�������ݿ�ʧ�ܣ�") && &EnableRestoreGUI(1) && return 0);

        &EnableRestoreGUI(1);

        exit(0);

        return 0;
}

# �ڽ�������ʾ��ʾ��Ϣ
sub ShowStatusMsg()
{
        if(defined $sb_mainwin)
        {
                $sb_mainwin->SetText(0, shift);
        }
}

# �����ݿ�����
sub OpenDB()
{
        #$SIG{'KILL'} = sub { threads->exit(); };
        &ShowStatusMsg("�����������ݿ⣬���Ժ򡣡���");

        if(1 == $logon_db)
        {
                return 0;
        }

        $logon_db = 1;

        if(&SqlOpenDB())
        {
                &ShowStatusMsg("���ݿ����ӳɹ���");
                $logon_db = 0;
                return 1;
        }
        else
        {
                &ShowStatusMsg("�޷��������ݿ⡣");
                return 0;
        }
}

# �ر����ݿ�����
sub CloseDB()
{
        &SqlCloseDB();

        &ShowStatusMsg("�ر����ݿ�ɹ���\n");
}

sub IsDBOK()
{
        if(! SqlIsDBOK())
        {
                Win32::GUI::MessageBox(undef, "���ݿ�δ׼���ã�");
                return 0;
        }

        return 1;
}
