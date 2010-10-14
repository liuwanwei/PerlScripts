use strict;

# 多音字读音的最大个数
my $max_initial_num = 3;

my $mandarin_file = "Mandarin.dat";
my $cfile = "uni2py_mapping_tbl.c";

# 删除旧的映射表文件
if(-e $cfile)
{
	system("del $cfile");
}

open(FH, $mandarin_file) or die $!;
open(OUT, ">$cfile") or die $!;

# 创建映射表文件头部信息 
&InsertHeader();

while(<FH>)
{
	chomp;

	my ($unicode, $pinyin) = split(/\t/);

	# 插入一条映射表记录
	&InsertRecord($unicode, $pinyin);
}

# 创建映射表文件尾部信息
&InsertTail();

close(FH);
close(OUT);

1;


sub InsertHeader()
{
	print OUT "\n\n\n";

	print OUT "#define MAX_INITIAL_NUM $max_initial_num    // tong yin zi zui da sheng mu shu liang\n";
	print OUT "typedef unsigned short UINT16;\n";
	print OUT "typedef unsigned char  UINT8;\n\n";
	print OUT "typedef struct {\n";
	print OUT "    UINT16 unicode;\n";
	print OUT "    UINT8  initial[MAX_INITIAL_NUM];\n";
	print OUT "}sg_py_mapping_tbl_t;\n";

	print OUT "\n\n\n";

	print OUT "const sg_py_mapping_tbl_t sg_py_mapping_tbl[] = {\n";
}

# Each record has the format below:
# { 0x6fc8, {n, n, n, n, n, n}},

sub InsertRecord()
{
	my $i = 0;

	# 当前要处理汉字的unicode编码，形如“4E48”
	my $unicode = $_[0];
	# 该汉字的拼音列表，可能是个多音字，所以要用list的形式
	my @pinyin_list = split(/ /, $_[1], $max_initial_num);
	# 该汉字拼音的声母列表
	my @empty_list = (0,0,0);
	# 该汉族拼音的声母的个数
	my $count = 0;

	foreach my $py (@pinyin_list)
	{
		# 是否超过多音字声母出现最大个数
		if($count ge $max_initial_num)
		{
			last;
		}

		# 判断当前读音的声母是否已经保存过
		my $exist = 0;

		# 取拼音的第一个字母作为声母，在速查中，z跟zh，s跟sh，c跟ch没有区别。
		my $initial = substr($py, 0, 1);
		foreach my $old (@empty_list)
		{
			my $tmp = "'".$initial."'";
			if($tmp eq $old)
			{
				$exist = 1;
				last;
			}
		}

		# 当前读音的声母没有保存过，需要添加到empty表中
		if($exist eq 0)
		{
			@empty_list[$count] = "'".$initial."'";
			$count++;
		}
	}

	# 将获取的信息组合成映射表的一条记录
	my $record = "{0x".$unicode.", {".$empty_list[0].", ".$empty_list[1].", ".$empty_list[2]."}}, ";

	print OUT $record;
	print OUT "\n";
}

sub InsertTail()
{
	print OUT "};\n";
	print OUT "\n\n\n";
}
