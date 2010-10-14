use strict;
use DBI();
use threads('yield',
	    'stack_size' => 64 * 4096,
    	    'exit' => 'threads_only',
            'stringify');
use threads::shared;

my $db="vote";
my $host="192.168.1.254";
my $user="liuwanwei";
my $pass="53554644";

my $dbh;

share($dbh);

# �����̴߳����ݿ�
my $thr = threads->create('OpenDB') or die "Thread->new : $@";

sub OpenDB()
{
	my $tmp;

	$tmp = DBI->connect("DBI:mysql:database=$db;host=$host", $user, $pass) 
		or print "�޷��������ݿ⣺".DBI->errstr . "\n";

	$dbh = \$tmp;
}

$thr->join();

if(defined $dbh)
{
	print "defined\n";
}
else
{
	print "not\n";
}

