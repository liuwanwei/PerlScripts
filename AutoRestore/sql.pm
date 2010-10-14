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

# 访问数据库的用户名和密码
my $user="sungeo";
my $pass="123";
# 用户信息表的名称
my $tbl_user = "xg_user";
# 用户备份信息表的名称
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
	# 当前目录
	my $cur_dir = getcwd();

	# 转换成windows格式，用'\'代替'/'
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

# 打开数据库连接
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

# 关闭数据库连接
sub SqlCloseDB()
{
        if(defined $dbh)
        {
                $dbh->disconnect();
        }

        undef $dbh;
}

# 更新上传开始数据，将flag标志置1
sub UpdateBackupRecord()
{
        my $username = shift;
        my $date     = shift;
        my $sql;

        $sql = "UPDATE $tbl_bk SET flag = " . $dbh->quote("yes") . " WHERE user = " . $dbh->quote($username) . " AND date = " . $dbh->quote($date);
        print "$sql\n";
        $dbh->do($sql) or (print "更新记录失败：". DBI->errstr && return);

        return 1;
}

# 插入一条上传开始数据到数据库
sub PrepareBackupRecord()
{
        my $username = shift;
        my $date = shift;
        my $sql;

        # 获取当前时间，转化成mysql的date数据类型

        # 从path中剔除备份文件的路径信息，仅留下文件名

        # FIXME 修改sql数据库，只保留用户名和日期两项，以后可能加入“注释”项，但path项再也不需要了，直接从date项中取
        # 生成sql插入语句
        $sql = "INSERT INTO $tbl_bk(user,date,flag) VALUES(" . $dbh->quote($username) . "," . $dbh->quote($date) . "," . $dbh->quote("_you_never_agree_with_me_") . ")";

        print "$sql\n";
        $dbh->do($sql) or (print "插入数据失败：" . DBI->errstr && return);

        return $sql;
}

# 搜索网站的用户名数据表，检查用户名是否存在，并且是否拥有备份权限
sub  QueryPrivilege()
{
        my $user = shift;
        my $pass = shift;

        my $sql;

        # FIXME 本机测试的密码没有进行md5，临时注释掉
        # $pass = md5_hex($pass);

        $sql = "SELECT * FROM $tbl_user WHERE user = " . $dbh->quote($user) . "AND pass = " . $dbh->quote($pass);
        my $sth = $dbh->prepare($sql);
        $sth->execute();

        my $rows = $sth->rows;

        $sth->finish();

        if($rows <= 0)
        {
                # 用户信息数据表中没有关于该用户的记录
                return -1;
        }

        return 0;
}

# 搜索网站的备份信息数据表，检查用户备份次数是否已到最大值
# 返回值：0， 超过；1，未超过
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

# 检查用户名在数据库中是否已注册
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

# 在备份记录表中根据用户名搜索用户备份记录，输出到一个arrary中
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
                # 将date字段返回
                push(@records, $$ref[2]);
        }

        return @records;
}

# 删除备份记录
sub DeleteBackupRecord()
{
        my $username = shift;
        my $date     = shift;
        my $sql;

        $sql = "DELETE FROM $tbl_bk WHERE user = " . $dbh->quote($username) . " AND date = " . $dbh->quote($date) . "LIMIT 1";
        print "$sql\n";
        $dbh->do($sql) or die "删除记录失败：" . DBI->errstr;

        return 1;
}

1;
