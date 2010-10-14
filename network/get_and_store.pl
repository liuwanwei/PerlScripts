use strict;
use LWP::Simple qw(get getstore);

exit print &GetGoogleCN;


sub GetGoogleCN
{
	my $html = get("http://www.google.cn");
	print $html;

	&getstore("http://www.google.cn", "google.html");

}

1;
