use strict;
use Cwd;
use Cwd 'abs_path';
use Net::xFTP;
#use Net::FTP;
use Win32::Process;
use Win32::FileOp;
use Win32;

# Ӧ�������ļ��ж�ȡ
#my $ftp_server = "192.168.1.137";

# ��ǰĿ¼
my $cur_dir = getcwd();

# ת����windows��ʽ����'\'����'/'
my $abs_path = abs_path($cur_dir);

my $ftp_server;
open(MYFILE, "$abs_path\\SmartHomeInfo.ini") or die "cannot open SmartHomeInfo.ini: $!\n";
my @contents = <MYFILE>;
my @ftp_server_line = grep /FtpServerIP/, @contents;
my ($infor, $ftp_server) = split(/=/, $ftp_server_line[0]);
chomp($ftp_server_line[0]);

# FIXME Ӧ���������ļ����ý����۵ķ�ʽ��ʾ
my $ftp_user   = "restore";
my $ftp_pass   = "sungeo_restore";

# my $ftp_user   = "hqx";
# my $ftp_pass   = "123";

# ��ftp�������ݵ����ص�Ŀ¼
my $local_dir = "DB_restored";

# �������ݴ��
# ���ݰ��ļ�����20090601.dat
# Ҳ��������ô��
sub PackBackupPacket()
{
        my $path;

        return $path;
}

# �ϴ��û����ݵ�FTP������
# �洢��ʽ��
# ��ftp�û���Ŀ¼�£�������$username��ͬ��Ŀ¼
# ��$usernameĿ¼�±��汸���ļ�
# Ĭ������£��ű�Ӧ�ø�ihouse������һ��Ŀ¼��DB����һ��Ŀ¼��
sub UploadBackupPacket()
{
        my $username  = shift;
        my $date = shift;

        die "This server needs Net::FTP!" unless (Net::xFTP->haveFTP());

        # ��Զ��FTP������
        my $ftp = Net::xFTP->new('FTP', $ftp_server,
                user => $ftp_user,
                password => $ftp_pass)
                or (print "Cannot connect to $ftp_server: $@" && return);

        #�Զ����ƴ��䷽ʽ���д���
        $ftp->binary;
        #or die "Unable to set mode to binary. ", $ftp->message;

        # ���FTP���������û���������Ŀ¼�Ƿ����
        if(! $ftp->isadir($username))
        {
                # Ŀ¼�����ڣ�����
                $ftp->mkdir($username) or die "mkdir($username) : $@";
        }

        # �л����û�����Ŀ¼
        $ftp->cwd($username) or die "cwd($username) : $@";

        # ��������Ŀ��Ŀ¼
        $ftp->mkdir($date) or die "mkdir($date) : $@";

        # �л�������Ŀ��Ŀ¼����ʼ����
        $ftp->cwd($date) or "die cwd($date) : $@";

        # �����ء�DB��Ŀ¼�µ������ԡ�.db��Ϊ��׺���ļ�ȫ���ϴ�������Ŀ��Ŀ¼
        my $dir;
               opendir($dir, "DB") or die "opendir(DB) : $!";
        my @files = grep {/.db$/ && -f "DB\\$_"} readdir($dir);

        foreach my $file (@files)
        {
                $ftp->put("DB\\$file", $file) or die "put($date) : $@";
        }

        # �Ͽ�����
        $ftp->quit();

        return 1;
}

# ��FTP������ɾ�����ݼ�¼
sub DeleteBackupPacket()
{
        my $username = shift;
        my $date = shift;

        # ��ɾ�����б��ݵ��ļ�����ɾ������Ŀ¼

        # ��Զ��FTP������
        my $ftp = Net::xFTP->new('FTP', $ftp_server,
                user => $ftp_user,
                password => $ftp_pass)
                or die "Cannot connect to $ftp_server: $@";

        # ���FTP���������û���������Ŀ¼�Ƿ����
        $ftp->isadir($username) or (print "isadir($username) : $@" && return);

        # �л����û�����Ŀ¼
        $ftp->cwd($username) or (print "cwd($username) : $@" && return);

        # �л�������Ŀ��Ŀ¼����ʼ����
        # $ftp->cwd($date) or "die cwd($date) : $@";

        #����������������ļ����Ƿ����
        $ftp->isadir($date) or (print "isadir($date) : $@" && return);

        # ���������ϡ�$date��Ŀ¼�µ����е��ļ�ȫ��ɾ��
        # ��ȡ���������б�
        my @files = $ftp->ls($date);

        # ���ɾ���ļ�
        foreach my $file (@files)
        {
                print "��FTPɾ���ļ� $file \n";
                $ftp->delete("$date\\$file") or die "delete($date\\$file) : $@";
        }

        # ɾ������Ŀ��Ŀ¼
        $ftp->rmdir($date) or die "rmdir($date) : $@";

        # �Ͽ�����
        $ftp->quit();

        return 1;
}

# �������ݲ��ָ���pc�����
sub DownloadBackupPacket()
{
        my $username= shift;
        my $date = shift;

        my $ftp = Net::xFTP->new('FTP', $ftp_server,
                user => $ftp_user,
                password => $ftp_pass)
                or die "Cannot connect to $ftp_server: $@";

        #���ó��Զ�������ʽ��������
        $ftp->binary;

        # ���FTP���������û���������Ŀ¼�Ƿ����
        if(! $ftp->isadir($username))
        {
                print "isaddr($username) : $@";
                return;
        }

        # �л����û�����Ŀ¼
        $ftp->cwd("$username\\$date") or die "cwd($username) : $@";

        # ��ȡ���������б�
        my @files = $ftp->ls();

        # �����ļ������ص�DB_restored��Ŀ¼
        if (! -d $local_dir)
        {
                mkdir($local_dir);
        }

        # ��������ļ�
        foreach my $file (@files)
        {
                # print "��FTP�����ļ� $file ������ $local_dir\\$file\n";
                $ftp->get($file, "$local_dir\\$file");
        }

        return 1;
}

# ��������PC�����ʹ���µ��û�����
sub RestorePCSoft()
{
        # Ҫkill�Ľ�������
        my ($ihouse, $server, $update) = qw(ihouse smarthomeser SmartHomeUpdate.exe);

        # �ر�iHouse��ؽ���
        &KillProcess($ihouse);

        &KillProcess($server);

        # �� $local_dir �е����ݿ��ļ�������DBĿ¼��
        &CopyFilesToDBDir();

        # FIXME ɾ��������������ʱĿ¼

        # ��������ihouse��ڳ���
        &RestartProcess($update);

        return 1;
}

# ���������Ҳ��������SmartHomeUpdate
sub RestartProcess()
{
        my $name = shift;

        my ($obj, $args);

        Win32::Process::Create($obj, $name, $args, 0, 0, $abs_path);

        return 1;
}

# ����PC���ǰ������FTP���µ������ݿ�������ȷλ��
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