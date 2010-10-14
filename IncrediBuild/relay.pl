
use strict;
use Win32::Registry;

# The keyname which stored the expired date.
my $key_name = "Interface\\{B7348B5D-B65D-4BF5-AF63-A3135249ACA7}\\ProxyStubClsid32";

# In vc:
# COleDateTime DateTime(2011, 3, 30, 23, 59, 59);
# DATE date = DATE(DateTime);
# We make the IncrediBuild expired at 2011.3.30.23.59.59
# 37BAE7FFDF84E340 6.10
# 37BAE7FF1F86E340 6.20
# 37BAE7FFDF89E340 7.20
# 37BAE7FFBF8DE340 8.20
my $expire_date = "37BAE7FFDF89E340";

my $T1 = substr($expire_date, 0, 4);
my $T2 = substr($expire_date, 4, 12);

my $M1 = "23EAEB06";
my $M2 = "103A";
my $M3 = "38C0";

my $key_content = "{".$M1."-".$M2."-".$M3."-".$T1."-".$T2."}";

my ($hkey, @key_list, $key, %values);

$HKEY_CLASSES_ROOT->Open($key_name, $hkey) or die $@;

$hkey->GetValues(\%values);

foreach (keys(%values))
{
	# default key name is NULL
	if($_ eq "")
	{
		# print $values{$_}[0], " ", $values{$_}[1], " ", $key_content;
		$hkey->SetValue($values{$_}[0], $values{$_}[1], $key_content);

		last;
	}
}


$hkey->Close();

print "OK.\n";
