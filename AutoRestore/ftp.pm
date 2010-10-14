use strict;
use Cwd;
use Cwd 'abs_path';
use Net::xFTP;
#use Net::FTP;
use Win32::Process;
use Win32::FileOp;
use Win32;

# 应从配置文件中读取
#my $ftp_server = "192.168.1.137";

# 当前目录
my $cur_dir = getcwd();

# 转换成windows格式，用'\'代替'/'
my $abs_path = abs_path($cur_dir);

my $ftp_server;
open(MYFILE, "$abs_path\\SmartHomeInfo.ini") or die "cannot open SmartHomeInfo.ini: $!\n";
my @contents = <MYFILE>;
my @ftp_server_line = grep /FtpServerIP/, @contents;
my ($infor, $ftp_server) = split(/=/, $ftp_server_line[0]);
chomp($ftp_server_line[0]);

# FIXME 应该在配置文件中用较曲折的方式表示
my $ftp_user   = "restore";
my $ftp_pass   = "sungeo_restore";

# my $ftp_user   = "hqx";
# my $ftp_pass   = "123";

# 从ftp下载数据到本地的目录
my $local_dir = "DB_restored";

# 本地数据打包
# 数据包文件名：20090601.dat
# 也许根本不用打包
sub PackBackupPacket()
{
        my $path;

        return $path;
}

# 上传用户数据到FTP服务器
# 存储方式：
# 在ftp用户根目录下，建立跟$username相同的目录
# 在$username目录下保存备份文件
# 默认情况下，脚本应该跟ihouse程序在一个目录，DB在下一级目录中
sub UploadBackupPacket()
{
        my $username  = shift;
        my $date = shift;

        die "This server needs Net::FTP!" unless (Net::xFTP->haveFTP());

        # 打开远端FTP服务器
        my $ftp = Net::xFTP->new('FTP', $ftp_server,
                user => $ftp_user,
                password => $ftp_pass)
                or (print "Cannot connect to $ftp_server: $@" && return);

        #以二进制传输方式进行传输
        $ftp->binary;
        #or die "Unable to set mode to binary. ", $ftp->message;

        # 检查FTP服务器以用户名命名的目录是否存在
        if(! $ftp->isadir($username))
        {
                # 目录不存在，创建
                $ftp->mkdir($username) or die "mkdir($username) : $@";
        }

        # 切换到用户备份目录
        $ftp->cwd($username) or die "cwd($username) : $@";

        # 创建备份目标目录
        $ftp->mkdir($date) or die "mkdir($date) : $@";

        # 切换到备份目标目录，开始工作
        $ftp->cwd($date) or "die cwd($date) : $@";

        # 将本地“DB”目录下的所有以“.db”为后缀的文件全部上传到备份目标目录
        my $dir;
               opendir($dir, "DB") or die "opendir(DB) : $!";
        my @files = grep {/.db$/ && -f "DB\\$_"} readdir($dir);

        foreach my $file (@files)
        {
                $ftp->put("DB\\$file", $file) or die "put($date) : $@";
        }

        # 断开连接
        $ftp->quit();

        return 1;
}

# 从FTP服务器删除备份记录
sub DeleteBackupPacket()
{
        my $username = shift;
        my $date = shift;

        # 先删除所有备份的文件，再删除备份目录

        # 打开远端FTP服务器
        my $ftp = Net::xFTP->new('FTP', $ftp_server,
                user => $ftp_user,
                password => $ftp_pass)
                or die "Cannot connect to $ftp_server: $@";

        # 检查FTP服务器以用户名命名的目录是否存在
        $ftp->isadir($username) or (print "isadir($username) : $@" && return);

        # 切换到用户备份目录
        $ftp->cwd($username) or (print "cwd($username) : $@" && return);

        # 切换到备份目标目录，开始工作
        # $ftp->cwd($date) or "die cwd($date) : $@";

        #检查以日期命名的文件夹是否存在
        $ftp->isadir($date) or (print "isadir($date) : $@" && return);

        # 将服务器上“$date”目录下的所有的文件全部删除
        # 获取备份数据列表
        my @files = $ftp->ls($date);

        # 逐个删除文件
        foreach my $file (@files)
        {
                print "从FTP删除文件 $file \n";
                $ftp->delete("$date\\$file") or die "delete($date\\$file) : $@";
        }

        # 删除备份目标目录
        $ftp->rmdir($date) or die "rmdir($date) : $@";

        # 断开连接
        $ftp->quit();

        return 1;
}

# 下载数据并恢复到pc软件中
sub DownloadBackupPacket()
{
        my $username= shift;
        my $date = shift;

        my $ftp = Net::xFTP->new('FTP', $ftp_server,
                user => $ftp_user,
                password => $ftp_pass)
                or die "Cannot connect to $ftp_server: $@";

        #设置成以二进制形式传输数据
        $ftp->binary;

        # 检查FTP服务器以用户名命名的目录是否存在
        if(! $ftp->isadir($username))
        {
                print "isaddr($username) : $@";
                return;
        }

        # 切换到用户备份目录
        $ftp->cwd("$username\\$date") or die "cwd($username) : $@";

        # 获取备份数据列表
        my @files = $ftp->ls();

        # 下载文件到本地的DB_restored子目录
        if (! -d $local_dir)
        {
                mkdir($local_dir);
        }

        # 逐个下载文件
        foreach my $file (@files)
        {
                # print "从FTP下载文件 $file 到本地 $local_dir\\$file\n";
                $ftp->get($file, "$local_dir\\$file");
        }

        return 1;
}

# 重新运行PC软件，使用新的用户数据
sub RestorePCSoft()
{
        # 要kill的进程名称
        my ($ihouse, $server, $update) = qw(ihouse smarthomeser SmartHomeUpdate.exe);

        # 关闭iHouse相关进程
        &KillProcess($ihouse);

        &KillProcess($server);

        # 将 $local_dir 中的数据库文件拷贝到DB目录下
        &CopyFilesToDBDir();

        # FIXME 删除下载下来的临时目录

        # 重新启动ihouse入口程序
        &RestartProcess($update);

        return 1;
}

# 重启软件、也就是启动SmartHomeUpdate
sub RestartProcess()
{
        my $name = shift;

        my ($obj, $args);

        Win32::Process::Create($obj, $name, $args, 0, 0, $abs_path);

        return 1;
}

# 重启PC软件前，将从FTP上下到的数据拷贝到正确位置
sub CopyFilesToDBDir()
{
        my $dir;
        my $src_dir = $local_dir;
        my $dst_dir = "DB\\";

        opendir($dir, $src_dir) or die "opendir($src_dir) : $!";
        my @files = grep {/.db$/ && -f "$src_dir\\$_"} readdir($dir);

        foreach my $file (@files)
        {
                Copy("$src_dir\\$file" => $dst_dir);
        }

        return 1;
}

1;

=head
my $test_user = "liuguohui";
my $test_date;
my @time = localtime();
$test_date = sprintf("%d%02d%02d%02d%02d%02d", $time[5] + 1900, $time[4] + 1, $time[3], $time[2], $time[1], $time[0]);

&UploadBackupPacket($test_user, $test_date);
=cut

#&RestorePCSoft();