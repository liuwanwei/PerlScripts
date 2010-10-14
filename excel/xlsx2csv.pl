use strict;
use Win32::OLE qw(in with);
use Win32::OLE::Const 'Microsoft Excel';

my $output="mailout.csv";

# ��Ҫ�������Ŀ���ļ�
open(FH, ">$output") or die "Can't open $output for writing!";

my $Excel = Win32::OLE->GetActiveObject('Excel.Application')
	    || Win32::OLE->new('Excel.Application', 'Quit');

my $book  = $Excel->Workbooks->Open("d:\\codes\\pl\\excel\\addressbook.xlsx");

my $sheet = $book->Worksheets('�°�ͨѶ¼');
my $count = $sheet->{'UsedRange'}->{'Rows'}->{'Count'};


# ��������ͨѶ¼�������ÿ���˵���Ϣ��ʹ֮����Foxmail��Ҫ��
my $i = 0;			# ��¼�Ŵ�0��ʼ
my $row = 3;		# �ӵ�3�п�ʼ������excel�ļ����ݾ�����

my $name;
my $cellphone;
my $shortnum;

print FH "����,�ֻ�,�̺�\n";

while($row < $count)
{
    # xml�ļ����±��1��ʼ
	$name      = $sheet->Cells($row, 3)->{'Value'};
	$cellphone = $sheet->Cells($row, 6)->{'Value'};
    $shortnum  = $sheet->Cells($row, 7)->{'Value'};
	
    # �����ĵ��м���ܳ��ֵı�����
	if(!defined($name)
	|| $name eq "�� ��")
	{
		$row++;
		next;
	}

    my $len = length $cellphone;
    if($len gt 11)
    {
        # ����������������ֻʹ�����һ������
        $cellphone = substr $cellphone, -11, 11;
    }
    elsif($len lt 11)
    {
        # ����λ�����ԣ�����
        $row ++;
        next;
    }

    if(! ($shortnum =~ /^[0-9]*$/i))
    {
        # ���̺�δ����ʱ���̺����óɿ�
        $shortnum = "";
    }
	
    print FH "$name,$cellphone,$shortnum,\n";
	
	$row++;
}

$book->Close(1);

close(FH);

