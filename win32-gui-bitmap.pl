#!perl -w

use strict;
use Win32::GUI();
use Win32::GUI::DIBitmap;

my ($DOS) = Win32::GUI::GetPerlWindow();
Win32::GUI::Hide($DOS);

my $W = new Win32::GUI::Window (
            -title    => "Win32::GUI::DIBitmap test",
            -pos      => [100, 100],
            -size     => [400, 400],
            -name     => "Window",
            );

my $dib = newFromFile Win32::GUI::DIBitmap('image.jpg') || die "can't open image.jpg";
my $hbitmap = $dib->ConvertToBitmap();
undef $dib;

$W->AddButton (
  -pos     => [100, 100],
  -size    => [200, 200],
  -bitmap  => $hbitmap,
  -name    => "Button",
  -visible => 1,
  );

$W->Show();
Win32::GUI::Dialog();

sub Window_Terminate 
{ 
	return -1;
}

