package time;

sub whence {
	my $function_name = shift;

	my $target_key = &variables::key($function_name);
	my $target_range = &variables::range_eval($function_name);
	if ($#{$target_range} >= 0) {
		${$data::cloud::data_stack}{$target_key}[${$target_range}[0]] = time;
	} else {
		${$data::cloud::data_stack}{$target_key}[0] = time;
	}
}

sub now {
	my $function_name = shift;

	my $target_key = &variables::key($function_name);
	my $target_range = &variables::range_eval($function_name);
	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
	${$data::cloud::data_stack}{$target_key}[0] = $hour.":".$min.":".$second." ".$mday."/".$mon."/".$year;
}

1;

