use strict;

# �����ֶ�����������
my $max_initial_num = 3;

my $mandarin_file = "Mandarin.dat";
my $cfile = "uni2py_mapping_tbl.c";

# ɾ���ɵ�ӳ����ļ�
if(-e $cfile)
{
	system("del $cfile");
}

open(FH, $mandarin_file) or die $!;
open(OUT, ">$cfile") or die $!;

# ����ӳ����ļ�ͷ����Ϣ 
&InsertHeader();

while(<FH>)
{
	chomp;

	my ($unicode, $pinyin) = split(/\t/);

	# ����һ��ӳ����¼
	&InsertRecord($unicode, $pinyin);
}

# ����ӳ����ļ�β����Ϣ
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

	# ��ǰҪ�����ֵ�unicode���룬���硰4E48��
	my $unicode = $_[0];
	# �ú��ֵ�ƴ���б������Ǹ������֣�����Ҫ��list����ʽ
	my @pinyin_list = split(/ /, $_[1], $max_initial_num);
	# �ú���ƴ������ĸ�б�
	my @empty_list = (0,0,0);
	# �ú���ƴ������ĸ�ĸ���
	my $count = 0;

	foreach my $py (@pinyin_list)
	{
		# �Ƿ񳬹���������ĸ����������
		if($count ge $max_initial_num)
		{
			last;
		}

		# �жϵ�ǰ��������ĸ�Ƿ��Ѿ������
		my $exist = 0;

		# ȡƴ���ĵ�һ����ĸ��Ϊ��ĸ�����ٲ��У�z��zh��s��sh��c��chû������
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

		# ��ǰ��������ĸû�б��������Ҫ��ӵ�empty����
		if($exist eq 0)
		{
			@empty_list[$count] = "'".$initial."'";
			$count++;
		}
	}

	# ����ȡ����Ϣ��ϳ�ӳ����һ����¼
	my $record = "{0x".$unicode.", {".$empty_list[0].", ".$empty_list[1].", ".$empty_list[2]."}}, ";

	print OUT $record;
	print OUT "\n";
}

sub InsertTail()
{
	print OUT "};\n";
	print OUT "\n\n\n";
}
