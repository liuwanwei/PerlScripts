use strict;

sub prototype_test
{
	my $a = 10;
	my $b = "10ab";
	my $c = 3;
	my $d = 3;

	# ���Ĵ�ӡ��ʽ��print����Ը�2�����ϵ���������Զ��ŷָ�����
	print $a * 10, "\n";

	# �����ַ������ӷ�ʽ���õ������n���ַ��������м���������ɳ���
	print $a.$b. "\n";

	# �ַ�������
	print $a x $c, "\n";

	$a = substr($b, 0, 2);
	$c = substr($b, 2, 2);

	print $a * 5, "\n";

	# ��ʱ���$c�а���a-f��perl�������ͻ�������ң������Զ�ת�����Σ���0��Ϊ����ֵ����cһ��
	print $c * 5, "\n";

	# $a��$d����
	print $a ** $d . "\n";
}


=hash_test
	perl������ע�͵ķ���	
=cut

sub hash_test()
{
	# ����Ҫ��С��������סhash��Ա��ע�ⶨ���һ����ԱΪ����ķ������������ţ�
	# ע����ݹؼ��ַ�����ֵ�ķ�ʽ���ô����š�hash����һ����ֺ���ֵ�ļ��ϡ�
	my %hash = (	
		"name"   => ['wwliu', 'liuwanwei'],
		"age"    => '29',
		"gender" => 'male',
	);

	print $hash{"name"}[0];
}

prototype_test();
#hash_test();
