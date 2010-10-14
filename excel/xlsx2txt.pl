use strict;
use Win32::OLE qw(in with);
use Win32::OLE::Const 'Microsoft Excel';

# 打开要输出到的目标文件
open(FH, ">mail_list.txt") or die "Can't open mail_list.txt for writing!";

my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
	    || Win32::OLE->new('Excel.Application', 'Quit');

my $book  = $Excel->Workbooks->Open("d:\\codes\\pl\\excel\\addressbook.xlsx");

my $sheet = $book->Worksheets('新版通讯录');
my $count = $sheet->{'UsedRange'}->{'Rows'}->{'Count'};



# 遍历整个通讯录，整理出每个人的信息，使之符合Foxmail的要求
my $i = 0;			# 记录号从0开始
my $row = 3;		# 从第3行开始读（由excel文件内容决定）

my $name;
my $mail_int;
my $mail_ext;
my $cellphone;
while($row < $count)
{
	$name      = $sheet->Cells($row, 2)->{'Value'};
	$cellphone = $sheet->Cells($row, 5)->{'Value'};
    $shortnum  = $sheet->Cells($row, 6)->{'Value'};
    #$mail_int  = $sheet->Cells($row, 7)->{'Value'};
    #$mail_ext  = $sheet->Cells($row, 8)->{'Value'};
	
	if(!defined($name)
	|| $name eq "姓 名")
	{
		$row++;
		next;
	}
	
	print "$name\n";
	
	# 为内网邮箱生成记录
	if(defined($mail_int))
	{	
		print FH "[Record$i]\n";
		print FH "姓名: $name\n";
		print FH "电子邮件地址: $mail_int\n";
		print FH "手机: $cellphone\n\n";	
		$i++;
	}
	
	# 如果有外网邮箱，为外网邮箱生成单独记录
	if(defined($mail_ext))
	{
		print FH "[Record$i]\n";
		print FH "姓名: $name (外网)\n";
		print FH "电子邮件地址: $mail_ext\n";
		print FH "手机: $cellphone\n\n";
		$i++;
	}
	
	$row++;
}

$book->Close(1);

close(FH);

