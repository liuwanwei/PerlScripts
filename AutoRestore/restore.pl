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

# 指定窗口尺寸
my ($w, $h) = qw(500, 350);
my ($btn_w, $btn_h) = qw(70, 21);

my $loginwin;
my $mainwin;

# 登录使用的用户名和密码，登录成功后保留，供“备份”和“恢复”消息处理函数使用
my ($username, $password);
# 是否登录成功：1，成功
my $login_ok = 0;

# 是否正在连接数据库
my $logon_db = 0;

# 是否下载成功
my $download_ok = 0;

# 登录窗口子控件
my ($label_help, $label_register, $label_input, $label_user, $tf_user, $btn_reg, $label_pass, $tf_pass, $btn_login, $sb_login);

# 主窗口子控件
my ($radio_backup, $btn_backup, $radio_restore, $listbox_record, $btn_delete, $btn_restore, $sb_mainwin);

if($#ARGV < 0)
{
       exit(1);
}

if($ARGV[0] ne "-xg")
{
       exit(1);
}

#判断配置文件中是否有ftp服务器和mysql服务器的信息，如果没有则把配置信息写入到SmartHomeInfo.ini中
sub CheckConfigFile()
{
         # 当前目录
         my $cur_dir = getcwd();

         # 转换成windows格式，用'\'代替'/'
         my $abs_path = abs_path($cur_dir);

         #这里如果用追加的方式（使用>>的方式）打开文件将不能独到文件中的内容，所以先用普通方式打开
         open(MYFILE, "$abs_path\\SmartHomeInfo.ini") or die "cannot open SmartHomeInfo.ini: $!\n";
         my @contents = <MYFILE>;
         my @mysql_server_line = grep /FtpServerIP/, @contents;
         if(!$mysql_server_line[0])
         {
                close(MYFILE);
                open(MYFILE, ">>$abs_path\\SmartHomeInfo.ini") or die "cannot open SmartHomeInfo.ini: $!\n";

                #向文件中写入数据
                print MYFILE "\nFtpServerIP=192.168.1.137\n";
                print MYFILE "MysqlHost=192.168.1.137";
                close(MYFILE);
         }
}


# 启动线程打开数据库。线程中打开的数据库句柄不能在父线程中共享，所以暂时不用线程实现。
#my $thr = threads->create('OpenDB') or die "Thread->new : $@";
# $SIG{'KILL'} = 'Main_Terminate';

&CheckConfigFile();

# 显示登陆界面
&ShowLoginWindow();

# 显示主界面
&ShowMainWindow();

sub ShowLoginWindow()
{
        $loginwin = Win32::GUI::Window->new(-name => "Login",
                                              -text => "数据备份与恢复",
                                           -width => $w,
                                           -height => $h,
                                              -minsize => [$w, $h],
                                              -maxsize => [$w, $h],
                                           -dialogui => 1,
                                           -tabstop => 1);

        $label_help = $loginwin->AddLabel(-text => "    在这里，您可以将iHouse中的配置信息上传备份到曦光公司专用服务器上，也可以将已经上传备份的配置信息恢复到现在的iHouse系统中。",
                                        #-foreground => 0x0000ff,
                                            -pos => [50, 30],
                                            -size => [400, 50]);

        $label_register = $loginwin->AddLabel(-text => "糟糕，我还没有注册！-------------------------------------------------", -pos => [50, 80], -size => [440, 20]);

        $btn_reg = $loginwin->AddButton(-name => "BtnRegister",
                                    -text => "马上注册",
                                        -pos  => [390, 105],
                                        -size => [70, 21],
                                    -tabstop => 1,
                                        -tip=> "注册用户信息");

        $label_input = $loginwin->AddLabel(-text => "请输入：-------------------------------------------------------------", -pos => [50, 145], -size => [440, 20]);

        $label_user = $loginwin->AddLabel(-text => "用户名：",
                                   -pos => [50, 182],
                                      -size=> [50, 30]);

        $tf_user = $loginwin->AddTextfield(-pos => [107, 182],
                                       -size => [233, 23],
                                       -tabstop => 1,
                                              -tip => "输入用户名");
        $tf_user->SetLimitText(32);

        $label_pass = $loginwin->AddLabel(-text => "密  码：",
                                         -pos => [50, 215],
                                          -size => [50, 40]);

        $tf_pass = $loginwin->AddTextfield(-name => "TFPass",
                                          -pos => [107, 215],
                                          -size => [233, 23],
                                          -password => 1,
                                                 -tabstop => 1,
                                            -tip => "输入密码");
        $tf_pass->SetLimitText(32);


        $btn_login = $loginwin->AddButton(-name => "BtnLogin",
                                            -text => "登录",
                                            -pos  => [390, 225],
                                            -size => [70, 21],
                                            -tabstop => 1,
                                            -tip => "登录备份服务器");
        $sb_login = $loginwin->AddStatusBar();

        # 移动窗口到屏幕正中央

        my $desk = Win32::GUI::GetDesktopWindow();
        my $dw = Win32::GUI::Width($desk);
        my $dh = Win32::GUI::Height($desk);
        my $x  = ($dw - $w) / 2;
        my $y  = ($dh - $h) / 2;
        $loginwin->Move($x, $y);

        # 显示窗口
        $loginwin->Show();

        # 焦点集中到用户名输入框中
        $tf_user->SetFocus();

        # 进入消息循环，否则窗口就会一闪而过
        Win32::GUI::Dialog();
}

# 对密码输入框键盘消息进行处理：
# 判断是否按下“ENTER”键，如果是，调用登录过程
# FIXME 当window的dialogui属性被设置成1时，控件将收不到enter消息。
sub TFPass_KeyDown()
{
        my $state = Win32::GUI::GetKeyState(13);

        if($state)
        {
                &BtnLogin_Click();
        }

        # print  $state. "\n";
}

# 在某项任务开始后，启用或禁用主界面控件
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

# 显示主界面
sub ShowMainWindow()
{
        # 创建窗口
        $mainwin = Win32::GUI::Window->new(-name => "Main",
                                              -text => "数据备份与恢复",
                                           -width => $w,
                                           -height => $h,
                                              -minsize => [$w, $h],
                                              -maxsize => [$w, $h],
                                           -dialogui => 1,
                                           -tabstop => 1);

        $radio_backup = $mainwin->AddRadioButton(-name => "RadioBackup",
                                              -text => "我要备份：-------------------------------------------------------",
                                              -pos  => [40, 24],
                                                    -size => [440, 20]);

        $btn_backup = $mainwin->AddButton(-name => "BtnBackup",
                                        -text => "开始备份",
                                        -pos  => [390, 55],
                                       -size => [$btn_w, $btn_h],
                                       -tabstop => 1,
                                              -tip  => "将智能家居系统信息备份到曦光服务器上");

        $radio_restore = $mainwin->AddRadioButton(-name => "RadioRestore",
                                                  -text => "我要恢复：-------------------------------------------------------",
                                                  -pos => [40, 90],
                                                    -size => [440, 20]);

=useless
        $btn_listrecord = $mainwin->AddButton(-name => "BtnListRecord",
                                        -text => "列出备份记录",
                                         -pos  => [50, 100],
                                         -size => [$btn_w, $btn_h - 10],
                                               -tabstop => 1,
                                        -tip  => "列出已备份的数据");
=cut

        $listbox_record = $mainwin->AddListbox(-name => "ListboxRecord",
                                            -multicolumn => 0,
                                                -pos  => [55, 120],
                                            -size => [325, 130],
                                                   -tabstop => 1,
                                            -tip  => "备份记录");

        $listbox_record->ItemHeight(20);

        $btn_delete = $mainwin->AddButton(-name => "BtnDeleteRecord",
                                       -text => "删除",
                                       -pos  => [55, 246],
                                       -size => [50, $btn_h],
                                       -tabstop => 1,
                                       -tip  => "删除选中的备份记录");
        # 刚开始列表框为空，所以禁用“删除”按钮
        $btn_delete->Enable(0);

        $btn_restore = $mainwin->AddButton(-name => "BtnRestore",
                                        -text => "开始恢复",
                                        -pos  => [390, 246],
                                        -size => [$btn_w, $btn_h],
                                        -tip  => "从选中的记录中恢复数据");
        # 刚开始列表框为空，所以禁用“开始恢复”按钮
        $btn_restore->Enable(0);

        $sb_mainwin = $mainwin->AddStatusBar();;

        # 移动窗口到屏幕正中央
        my $desk = Win32::GUI::GetDesktopWindow();
        my $dw = Win32::GUI::Width($desk);
        my $dh = Win32::GUI::Height($desk);
        my $x  = ($dw - $w) / 2;
        my $y  = ($dh - $h) / 2;
        $mainwin->Move($x, $y);

        # 显示窗口
        $mainwin->Show();

        &BtnListRecord_Click();

        # 默认进入“备份”操作区
        $radio_backup->Checked(1);
        RadioBackup_Click();

        # 进入消息循环，否则窗口就会一闪而过
        Win32::GUI::Dialog();

}

sub Main_Terminate()
{
        # print "退出主窗口\n";

        # 在恢复的最后一步，等待用户输入“确定”时，如果发生意外，在这里继续完成数据恢复
        if($download_ok)
        {
                # 用下载下来的文件更新本地数据库
                &RestorePCSoft() or (Win32::GUI::MessageBox(undef, "更新数据库失败！") && &EnableRestoreGUI(1) && return 0);
        }

        &ShowStatusMsg("正在关闭数据库，请稍候。。。");

        #$thr->kill('KILL');
        #$thr->join();

        &CloseDB();

        exit(0);
}

sub Login_Terminate()
{
        print "退出登录窗口\n";

        # 登录失败后，强行退出登录窗口时，需要关闭数据库连接
        if($login_ok == 0)
        {
                &CloseDB();
        }

        exit(0);
}

# 登录时，禁用登录按钮
sub EnableLoginWinGUI()
{
        my $flag = shift;

        $btn_login->Enable($flag);
}

# “注册”按钮消息处理函数
sub BtnRegister_Click()
{
        my $iexploere = &GetDefaultIExplorerDir();

        #print "$iexploere\n";

        # 找出默认浏览器的程序名，把参数去掉
        # 第一对引号中包含的内容就是浏览器exe的绝对路径，后面跟空格，然后是参数表。
        # 需要移除参数表。
        # 目前测试共支持ff和ie。
        $iexploere =~ /(^"[\w\W]*") /;

        $iexploere = $1;

        #print "$iexploere\n";

        system($iexploere, "http://www.sungeo.cn/register.php");
}

# “登录”按钮消息处理函数
sub BtnLogin_Click()
{
        # 检查用户名是否符合输入要求
        if(! &PreCheckUserinfo())
        {
                return 0;
        }

        #print "$username, $password |||\n";

        $sb_login->SetText(0, "登录中，请稍候。。。");

        # 尝试打开数据库
        if(! &OpenDB())
        {
                &EnableLoginWinGUI(1);
                $sb_login->SetText(0, "连接数据库失败！");
                return 0;
        }

        # 验证用户信息是否合法
        &ShowStatusMsg("正在搜索用户 ".$username." 的信息... ");
        if(! &CheckUserinfo($username, $password))
        {
                $tf_user->SetFocus();
                &EnableLoginWinGUI(1);

                $username = "";
                $password = "";
                $sb_login->SetText(0, "");

                Win32::GUI::MessageBox(undef, "请确认用户信息是否正确！");
                &ShowStatusMsg("");

                return 0;
        }
        else
        {
                # FIXME 退出登录窗，进入主界面
                # 现在没有退出，只是隐藏了。
                $loginwin->Hide();
                Win32::GUI::PostQuitMessage();

                $login_ok = 1;

                return 1;
        }

}

# 检查用户名输入是否合法
sub PreCheckUserinfo()
{
        my $user = $tf_user->Text();
        my $pass = $tf_pass->Text();

        # print "$user, $pass\n";

        if($user eq "" or $pass eq "")
        {
                Win32::GUI::MessageBox(undef, "用户身份信息不完整，请输入！");
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

        # 对用户名和密码的合法性做验证
        if($user =~ / / or $pass =~ / /)
        {
                Win32::GUI::MessageBox(undef, "用户名和密码中不能有空格");
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

# “备份”按钮消息处理函数
sub BtnBackup_Click()
{
        # 禁用控件
        &EnableBackupGUI(0);

        &IsDBOK() or return -1;

        # 检查备份次数是否超过最大值，超过后不再允许备份
        if(! &CheckBackupTimes($username))
        {
                Win32::GUI::MessageBox(undef, "用户备份次数已经到达最大值", "错误");
                &EnableBackupGUI(1);
                return 0;
        }

        #间隔一秒钟是为了防止用户在一秒钟内不止一次点击了备份按钮，造成生成日期的重复
        sleep(1);

        # 生成当前日期串，记录备份还原点
        my $date;
        my @time = localtime();
        $date = sprintf("%d%02d%02d%02d%02d%02d", $time[5] + 1900, $time[4] + 1, $time[3], $time[2], $time[1], $time[0]);

        # （不打包可以吗？可以！）将本地数据库文件打成一个包
        # my $packet_path = &PackBackupPacket();

        &ShowStatusMsg("备份中。。。。。。");

        # 向数据库备份数据表插入一条记录，表明要开始插入，但flag标志要置为0，表明尚未插入完成，防止ftp过程失败造成ftp和mysql数据不同步
        if(! &PrepareBackupRecord($username, $date))
        {
                &ShowStatusMsg("备份失败，请稍后尝试。");
        }

        # 将打包好的备份数据传送到ftp服务器
        if(! &UploadBackupPacket($username, $date))
        {
                &ShowStatusMsg("备份失败，请检查网络连接。");
                return;
        }

        # 更新数据库备份数据表的记录，将flag标志置1，表明插入完毕，如果这里失败，那就会造成数据不同步。
        if(! &UpdateBackupRecord($username, $date))
        {
                &ShowStatusMsg("备份失败，请跟技术支持人员取得联系。");
        }

        &EnableBackupGUI(1);

        &BtnListRecord_Click();

        &ShowStatusMsg("备份成功！");

        return;
}

# “列出备份记录”按钮消息处理函数
sub BtnListRecord_Click()
{
        # 清楚列表框中旧的内容
        $listbox_record->ResetContent();

        &IsDBOK() or return -1;

        # 从数据库提取该用户名下的所有备份记录
        my @records = &QueryBackupRecord($username);

        foreach my $item (@records)
        {
                # 显示“用户名+备份日期”形式的备份记录
                $listbox_record->AddString($username . " " . $item);
        }

        return 0;
}

# “删除”按钮消息处理函数
sub BtnDeleteRecord_Click()
{
        # 打开数据库
        if(! &OpenDB())
        {
                return 0;
        }

        my $index;
        my $string;
        if(($index = $listbox_record->GetCurSel()) < 0)
        {
                Win32::GUI::MessageBox(undef, "请从列表框中选择一个备份时间点");
                return 0;
        }

        &EnableRestoreGUI(0);

        # 列表框内必须有数据，所以在此之前username的合法性已经经过检验，此时不需再次检验，直接提取用户名和备份日期

        $string = $listbox_record->GetString($index);

        # 提取用户名和备份日期
        my ($username, $date) = split(/ /, $string);
        print "备份文件信息：$username, $date \n";

        # 首先从FTP服务器上删除
        if(! &DeleteBackupPacket($username, $date))
        {
                Win32::GUI::MessageBox(undef, "从文件服务器删除数据失败！");
                &EnableRestoreGUI(1);
                return;
        }

        # 其次从MYSQL上删除
        &ShowStatusMsg("删除中，请稍候。。。");
        &DeleteBackupRecord($username, $date) or (Win32::GUI::MessageBox(undef, "从数据库服务器删除数据失败！") && &EnableRestoreGUI(1) && return -1);
        &ShowStatusMsg("删除成功！");


        # 从列表框中删除显示
        $listbox_record->DeleteString($index);

        &ShowStatusMsg("删除成功！");

        &EnableRestoreGUI(1);
        return 0;
}

# “开始恢复”按钮消息处理函数
sub BtnRestore_Click()
{
        my $index;
        my $string;

        if(($index = $listbox_record->GetCurSel()) < 0)
        {
                Win32::GUI::MessageBox(undef, "请从列表框中选择一个备份时间点");
                return 0;
        }

        if(! &OpenDB())
        {
                return 0;
        }

        &ShowStatusMsg("正在恢复中，请稍候。。。");

        &EnableRestoreGUI(0);

        # 列表框内必须有数据，所以在此之前username的合法性已经经过检验，此时不需再次检验，直接提取用户名和备份日期

        $string = $listbox_record->GetString($index);

        # 提取用户名和备份日期
        my ($username, $date) = split(/ /, $string);
        # print "备份文件信息：$username, $date \n";

        # 从ftp服务器下载备份好的文件
        if(! &DownloadBackupPacket($username, $date))
        {
                Win32::GUI::MessageBox(undef, "下载备份文件失败！");
                &ShowStatusMsg("下载备份文件失败！");
                       &EnableRestoreGUI(1);
                return;
        }

        &ShowStatusMsg("文件下载成功，开始重新启动软件！");

        $download_ok = 1;

        Win32::GUI::MessageBox(undef, "恢复成功，马上重启iHouse", "配置信息日期：$date");

        # 用下载下来的文件更新本地数据库
        &RestorePCSoft() or (Win32::GUI::MessageBox(undef, "更新数据库失败！") && &EnableRestoreGUI(1) && return 0);

        &EnableRestoreGUI(1);

        exit(0);

        return 0;
}

# 在界面上显示提示信息
sub ShowStatusMsg()
{
        if(defined $sb_mainwin)
        {
                $sb_mainwin->SetText(0, shift);
        }
}

# 打开数据库连接
sub OpenDB()
{
        #$SIG{'KILL'} = sub { threads->exit(); };
        &ShowStatusMsg("正在连接数据库，请稍候。。。");

        if(1 == $logon_db)
        {
                return 0;
        }

        $logon_db = 1;

        if(&SqlOpenDB())
        {
                &ShowStatusMsg("数据库连接成功。");
                $logon_db = 0;
                return 1;
        }
        else
        {
                &ShowStatusMsg("无法连接数据库。");
                return 0;
        }
}

# 关闭数据库连接
sub CloseDB()
{
        &SqlCloseDB();

        &ShowStatusMsg("关闭数据库成功！\n");
}

sub IsDBOK()
{
        if(! SqlIsDBOK())
        {
                Win32::GUI::MessageBox(undef, "数据库未准备好！");
                return 0;
        }

        return 1;
}
