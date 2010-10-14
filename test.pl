use strict;

sub prototype_test
{
	my $a = 10;
	my $b = "10ab";
	my $c = 3;
	my $d = 3;

	# 灵活的打印方式，print后可以跟2个以上的输出对象以逗号分隔即可
	print $a * 10, "\n";

	# 灵活的字符串连接方式，用点号连接n个字符串，或有几个数字组成长串
	print $a.$b. "\n";

	# 字符串复制
	print $a x $c, "\n";

	$a = substr($b, 0, 2);
	$c = substr($b, 2, 2);

	print $a * 5, "\n";

	# 此时如果$c中包含a-f，perl解释器就会产生混乱，不会自动转成整形，用0最为返回值，跟c一样
	print $c * 5, "\n";

	# $a的$d次幂
	print $a ** $d . "\n";
}


=hash_test
	perl中批量注释的方法	
=cut

sub hash_test()
{
	# 这里要用小括号来扩住hash成员，注意定义第一个成员为数组的方法，用中括号，
	# 注意根据关键字访问数值的方式，用大括号。hash就是一组键字和数值的集合。
	my %hash = (	
		"name"   => ['wwliu', 'liuwanwei'],
		"age"    => '29',
		"gender" => 'male',
	);

	print $hash{"name"}[0];
}

prototype_test();
#hash_test();
