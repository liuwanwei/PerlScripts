#!perl -w

# execlog - run a program with exec and log the output
# perl/win32::GUI implementation

use strict;
use warnings;
use threads;
use Net::PcapUtils;
use Win32::GUI qw( MB_ICONQUESTION MB_ICONINFORMATION MB_YESNOCANCEL
                   MB_OK IDYES IDCANCEL );
                  
#create menu
my @menu_defn = (
    "&File"  => "File",
    "   > -"                      => 0,
    "   > E&xit"                  => { -name => "File_Exit", -onClick => sub { -1; } },
    "&Help"                       => "Help",
    "   > &About "                => { -name => "About", -onClick => \&Notepad_OnAbout },
);
my $menu = Win32::GUI::Menu->new(@menu_defn);

#create main window
my $main = Win32::GUI::Window->new(
    -name   => 'Main',
    -width  => 600,
    -height => 400,
    -text   => 'ExecLog',
    -menu  => $menu,
);

$main->AddTextfield(
    -name => "inputwin",
    -left => 10,
    -top  => 10,
    -width => 370,
    -height => 20,
    -multiline => 0,
    -autohscroll => 0,
    -autovscroll => 0,
    -prompt => ["command: ", 50],
    -wantreturn => 0,
);

$main->AddTextfield(
    -name => "resultwin",
    -left => 10,
    -top  => 50,
    -width => 500,
    -height => 330,
    -multiline => 1,
    -autohscroll => 1,
    -autovscroll => 1,
    -vscroll     => 1,
    #-hscroll     => 1,
);

$main->AddButton(-name => 'btn_run', -text => 'Run',-left => 440, -top => 10, -ok => 1,);
$main->AddButton(-name => 'btn_save', -text => 'Save',-left => 490, -top => 10, -ok => 1,);
$main->AddButton(-name => 'btn_quit', -text => 'Quit',-left => 545, -top => 10, -cancel => 1, );

my ($DOS) = Win32::GUI::GetPerlWindow();
Win32::GUI::Hide($DOS);

# initialization
my $w = $main->ScaleWidth();
my $h = $main->ScaleHeight();
my $desk = Win32::GUI::GetDesktopWindow();
my $dw = Win32::GUI::Width($desk);
my $dh = Win32::GUI::Height($desk);
my $x = ($dw - $w) / 2;
my $y = ($dh - $h) / 2;
$main->Move($x, $y);
$main->Show();

#Windows message loop
Win32::GUI::Dialog(); 

exit(0);

## ------------ subroutines -----------------

# window event handler
sub Main_Terminate {
    -1; #terminate the message loop
}

sub Main_Resize {
    $main->resultwin->Resize($main->ScaleWidth - 20, $main->ScaleHeight - 40);
}
  
sub Main_Minimize {
    $main->Disable();
    $main->Hide();
    Win32::GUI::Hide($DOS); #hide the DOS console window
    return 1;
}

# About box
sub Notepad_OnAbout {
    my $self = shift;

    $self->MessageBox(
        "ExecLog in perl.\r\nmade by bilbo.",
        "About",
        MB_ICONINFORMATION | MB_OK,
    );

    0;
}


sub btn_run_Click { 
    my $str = undef;
    $str = $main->inputwin->GetLine(0);
    if (defined($str))
    {
        my @files = qx|$str|;
        foreach (@files )
        {
            $main->resultwin->Append($_);
            $main->resultwin->Append("\r\n");
        }
    }
}

sub btn_save_Click { 
    my $file = "log.txt";
    open(FILE, ">>".$file);
    select(FILE);
    my $contents = $main->resultwin->Text();
    print $contents;
    close(FILE);
}

sub btn_quit_Click { 
    -1; #terminate the message loop
}


