use strict;
use DBI();

my $db="test";
my $host="192.168.1.213";
my $user="liuwanwei";
my $pass="53554644";
my $dbh = DBI->connect("DBI:mysql:database=$db;host=$host", $user, $pass) 
	or die "�޷��������ݿ⣺".DBI->errstr;





$dbh->disconnect();


=head1
	�����ݿ��в���������ݣ�����Ϊ���ݿ���	
=cut
sub InsertTestData()
{
	my $mysql_handle = shift;

	my ($name, $email, $address, $cellphone, $sql);

	for(my $i = 0; $i < 50; $i ++)
	{
		$name     = sprintf("%02d", $i + 1);
		$email    = sprintf("%02d\@sungeo.com", $i + 1);
		$address  = sprintf("%02d-hn-ly", $i + 1);
		$cellphone= sprintf("%08d", $i + 1);
		$sql = "INSERT INTO clients VALUES(" . $dbh->quote($name) . "," . $dbh->quote($email) . "," . $dbh->quote($address) . "," . $dbh->quote($cellphone) . ")";
		print $sql, "\n";
		$dbh->do($sql);
	}

	# ��ʾ�������ݱ�
	# my $msg = $dbh->do("show tables");
}
