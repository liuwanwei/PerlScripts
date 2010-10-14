#!/bin/perl

use strict;
use Net::FTP;
use Cwd;

my $action = "upload";

if($#ARGV != -1)
{
	if($ARGV[0] =~ /-d/i)
	{
		$action = "download";
	}

	shift;
}

my $server =  $ARGV[0] || '192.168.1.237';
my $user   =  $ARGV[1] || 'wwliu';
my $pass   =  $ARGV[2] || 'wwliu';
my $packet =  $ARGV[3] || 'demo.tgz';
my $cwd    =  getcwd();
my $ftp;


$ftp = Net::FTP->new($server, Debug=>0) or die "Cannot connect to $server: $@";

$ftp->login($user, $pass) or die $ftp->message; 

#$ftp->cwd($cwd) or die $ftp->message;

$ftp->binary();

if($action eq "upload")
{
	system("tar zcvf $packet demo/");
	$ftp->put($packet) or die $ftp->message;
}
else
{
	$ftp->get($packet) or die $ftp->message;
}

$ftp->quit();
