use strict;
use Win32::OLE qw(in with);
use Win32::OLE::Const 'Microsoft Excel';

my $output="mailout.csv";

# 打开要输出到的目标文件
open(FH, ">$output") or die "Can't open $output for writing!";

my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
	    || Win32::OLE->new('Excel.Application', 'Quit');

my $book  = $Excel->Workbooks->Open("d:\\codes\\pl\\excel\\addressbook.xlsx");

my $sheet = $book->Worksheets('新版通讯录');
my $count = $sheet->{'UsedRange'}->{'Rows'}->{'Count'};


# 遍历整个通讯录，整理出每个人的信息，使之符合Foxmail的要求
my $i = 0;			# 记录号从0开始
my $row = 3;		# 从第3行开始读（由excel文件内容决定）

my $name;
my $cellphone;
my $shortnum;

print FH "姓名,手机,短号\n";

while($row < $count)
{
    # xml文件列下标从1开始
	$name      = $sheet->Cells($row, 3)->{'Value'};
	$cellphone = $sheet->Cells($row, 6)->{'Value'};
    $shortnum  = $sheet->Cells($row, 7)->{'Value'};
	
    # 跳过文档中间可能出现的标题栏
	if(!defined($name)
	|| $name eq "姓 名")
	{
		$row++;
		next;
	}

    my $len = length $cellphone;
    if($len gt 11)
    {
        # 处理号码过多的情况，只使用最后一个号码
        $cellphone = substr $cellphone, -11, 11;
    }
    elsif($len lt 11)
    {
        # 号码位数不对，跳过
        $row ++;
        next;
    }

    if(! ($shortnum =~ /^[0-9]*$/i))
    {
        # “短号未开”时，短号设置成空
        $shortnum = "";
    }
	
    print FH "$name,$cellphone,$shortnum,\n";
	
	$row++;
}

$book->Close(1);

close(FH);

