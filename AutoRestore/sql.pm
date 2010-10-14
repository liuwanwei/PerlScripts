use DBI();
use DBD::mysql;
use Win32::GUI();
use Digest::MD5 qw(md5_hex);
use threads::shared;
use Cwd;
use Cwd 'abs_path';

my $db="xgnew";
#my $host="192.168.1.137";
#my $host="127.0.0.1";

# �������ݿ���û���������
my $user="sungeo";
my $pass="123";
# �û���Ϣ�������
my $tbl_user = "xg_user";
# �û�������Ϣ�������
my $tbl_bk   = "xg_ihouse_bk";
my $max_bk_times = 5;

#my $dbh:shared;

my $dbh;
sub SqlIsDBOK()
{
        if(! defined $dbh)
        {
                return 0;
        }

        return 1;
}

sub GetHostIP()
{
	# ��ǰĿ¼
	my $cur_dir = getcwd();

	# ת����windows��ʽ����'\'����'/'
	my $abs_path = abs_path($cur_dir);

	my $host;
	open(MYFILE, "$abs_path\\SmartHomeInfo.ini") 
		or die "cannot open SmartHomeInfo.ini: $!\n";

	my @contents = <MYFILE>;
	my @mysql_server_line = grep /MysqlHost/, @contents;
	my ($infor, $host) = split(/=/, $mysql_server_line[0]);
	chomp($host);	

	return $host;
}

# �����ݿ�����
sub SqlOpenDB()
{
	my $host = &GetHostIP();

        if(defined $dbh)
        {
                return 1;
        }

        $dbh =DBI->connect("DBI:mysql:database=$db;host=$host", $user, $pass) ;

        if(defined $dbh)
        {
                return 1;
        }
        else
        {
                return 0;
        }
}

# �ر����ݿ�����
sub SqlCloseDB()
{
        if(defined $dbh)
        {
                $dbh->disconnect();
        }

        undef $dbh;
}

# �����ϴ���ʼ���ݣ���flag��־��1
sub UpdateBackupRecord()
{
        my $username = shift;
        my $date     = shift;
        my $sql;

        $sql = "UPDATE $tbl_bk SET flag = " . $dbh->quote("yes") . " WHERE user = " . $dbh->quote($username) . " AND date = " . $dbh->quote($date);
        print "$sql\n";
        $dbh->do($sql) or (print "���¼�¼ʧ�ܣ�". DBI->errstr && return);

        return 1;
}

# ����һ���ϴ���ʼ���ݵ����ݿ�
sub PrepareBackupRecord()
{
        my $username = shift;
        my $date = shift;
        my $sql;

        # ��ȡ��ǰʱ�䣬ת����mysql��date��������

        # ��path���޳������ļ���·����Ϣ���������ļ���

        # FIXME �޸�sql���ݿ⣬ֻ�����û�������������Ժ���ܼ��롰ע�͡����path����Ҳ����Ҫ�ˣ�ֱ�Ӵ�date����ȡ
        # ����sql�������
        $sql = "INSERT INTO $tbl_bk(user,date,flag) VALUES(" . $dbh->quote($username) . "," . $dbh->quote($date) . "," . $dbh->quote("_you_never_agree_with_me_") . ")";

        print "$sql\n";
        $dbh->do($sql) or (print "��������ʧ�ܣ�" . DBI->errstr && return);

        return $sql;
}

# ������վ���û������ݱ�����û����Ƿ���ڣ������Ƿ�ӵ�б���Ȩ��
sub  QueryPrivilege()
{
        my $user = shift;
        my $pass = shift;

        my $sql;

        # FIXME �������Ե�����û�н���md5����ʱע�͵�
        # $pass = md5_hex($pass);

        $sql = "SELECT * FROM $tbl_user WHERE user = " . $dbh->quote($user) . "AND pass = " . $dbh->quote($pass);
        my $sth = $dbh->prepare($sql);
        $sth->execute();

        my $rows = $sth->rows;

        $sth->finish();

        if($rows <= 0)
        {
                # �û���Ϣ���ݱ���û�й��ڸ��û��ļ�¼
                return -1;
        }

        return 0;
}

# ������վ�ı�����Ϣ���ݱ�����û����ݴ����Ƿ��ѵ����ֵ
# ����ֵ��0�� ������1��δ����
sub CheckBackupTimes()
{
        my $username = shift;
        my $sql;
        my $sth;

        $sql = "SELECT * FROM $tbl_bk WHERE user = " . $dbh->quote($username) . " AND flag = " . $dbh->quote("yes");
        $sth = $dbh->prepare($sql) or die "prepare() : " . $dbh->errstr;
        print "$sql\n";
        $sth->execute() or (die "execute() : " . $dbh->errstr);

        print "rows = " . $sth->rows(). "\n";
        if($sth->rows() >= $max_bk_times)
        {
                $sth->finish();
                return 0;
        }
        else
        {
                $sth->finish();
                return 1;
        }
}

# ����û��������ݿ����Ƿ���ע��
sub CheckUserinfo()
{
        my $username = shift;
        my $password = shift;

        if(0 != &QueryPrivilege($username, $password))
        {
                return 0;
        }

        return $username;
}

# �ڱ��ݼ�¼���и����û��������û����ݼ�¼�������һ��arrary��
sub QueryBackupRecord()
{
        my $sql;
        my $sth;
        my @records;

        my $username = shift;

        $sql = "SELECT * FROM $tbl_bk WHERE user = " . $dbh->quote($username) . " AND flag = " . $dbh->quote("yes");
        $sth = $dbh->prepare($sql) or (&EnableGUI(1) && die "prepare() : " . $dbh->errstr);
        print "$sql\n";
        $sth->execute() or (&EnableGUI(1) && die "execute() : " . $dbh->errstr);

        print "rows = " . $sth->rows(). "\n";

        while(my $ref = $sth->fetchrow_arrayref())
        #while(($user,$date,$flag) = $sth->fetchrow_arrayref())
        {
                # ��date�ֶη���
                push(@records, $$ref[2]);
        }

        return @records;
}

# ɾ�����ݼ�¼
sub DeleteBackupRecord()
{
        my $username = shift;
        my $date     = shift;
        my $sql;

        $sql = "DELETE FROM $tbl_bk WHERE user = " . $dbh->quote($username) . " AND date = " . $dbh->quote($date) . "LIMIT 1";
        print "$sql\n";
        $dbh->do($sql) or die "ɾ����¼ʧ�ܣ�" . DBI->errstr;

        return 1;
}

1;
