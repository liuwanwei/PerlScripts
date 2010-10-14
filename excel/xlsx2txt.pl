use strict;
use Win32::OLE qw(in with);
use Win32::OLE::Const 'Microsoft Excel';

# ��Ҫ�������Ŀ���ļ�
open(FH, ">mail_list.txt") or die "Can't open mail_list.txt for writing!";

my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
	    || Win32::OLE->new('Excel.Application', 'Quit');

my $book  = $Excel->Workbooks->Open("d:\\codes\\pl\\excel\\addressbook.xlsx");

my $sheet = $book->Worksheets('�°�ͨѶ¼');
my $count = $sheet->{'UsedRange'}->{'Rows'}->{'Count'};



# ��������ͨѶ¼�������ÿ���˵���Ϣ��ʹ֮����Foxmail��Ҫ��
my $i = 0;			# ��¼�Ŵ�0��ʼ
my $row = 3;		# �ӵ�3�п�ʼ������excel�ļ����ݾ�����

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
	|| $name eq "�� ��")
	{
		$row++;
		next;
	}
	
	print "$name\n";
	
	# Ϊ�����������ɼ�¼
	if(defined($mail_int))
	{	
		print FH "[Record$i]\n";
		print FH "����: $name\n";
		print FH "�����ʼ���ַ: $mail_int\n";
		print FH "�ֻ�: $cellphone\n\n";	
		$i++;
	}
	
	# ������������䣬Ϊ�����������ɵ�����¼
	if(defined($mail_ext))
	{
		print FH "[Record$i]\n";
		print FH "����: $name (����)\n";
		print FH "�����ʼ���ַ: $mail_ext\n";
		print FH "�ֻ�: $cellphone\n\n";
		$i++;
	}
	
	$row++;
}

$book->Close(1);

close(FH);

