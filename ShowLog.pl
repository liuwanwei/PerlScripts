use strict;

my @date     = localtime();
my $log_file = sprintf(".\\Log\\%d%02d%02d.log", ($date[5] + 1900), ($date[4] + 1), $date[3]);
my $last_mod_time;
my $curr_mod_time;
my $last_line = 0;

# jump to the last line
$last_line = &PrintExtraMessage($last_line, 0);

while(1)
{
	my $curr_mod_time = -M $log_file;

	if($curr_mod_time eq $last_mod_time)
	{
		sleep(1);
	}
	else
	{
		$last_line = &PrintExtraMessage($last_line, 1);
		$last_mod_time = $curr_mod_time;
	}
}

sub PrintExtraMessage()
{
	my $HANDLE;
	my $last_line_number = $_[0];
	my $need_print = $_[1];
	my $cur_line_number = $last_line_number;

	open($HANDLE, "<$log_file");# or die "Cannot open $log_file";
	while(<$HANDLE>) 
	{
		next if $. <= $last_line_number;

		if($need_print == 1)
		{
			print "$_";
		}

		$cur_line_number  = $.;
	}
	close($HANDLE);

	return $cur_line_number;
}

