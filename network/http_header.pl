#!/usr/bin/perl

require HTTP::Headers;
require HTTP::Request;
require HTTP::Response;
require LWP::UserAgent;

use strict;

my $hdr;
$hdr = HTTP::Headers->new;
$hdr->header(HOST => 'client-list.pplive.cn',
		     If_None_Match => 'c0dae3471eadaa801b3fa62ed197e6',
	         Accept_Encoding => 'gzip, deflate',
	         User_Agent => 'my-web-client/0.01');
my $req;
$req = HTTP::Request->new('GET' => "/catalog.xml");
$req->header($hdr);

my $ua;
$ua = LWP::UserAgent->new;

my $resp;
$resp = $ua->request($req);

if($resp->is_success)
{
		print $resp->decoded_content;
}
else
{
		print STDERR $resp->status_line, "\n";
}

