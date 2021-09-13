package iterate;

sub foreach {
	my $function_name = shift;
	my $arguments = shift;

	my $target_key = &variables::key(${$arguments}[0]);
	my $source_key = &variables::key(${$arguments}[1]);
	my $source_range = &variables::range_eval(${$arguments}[1]);
	my $program = &variables::value(${$arguments}[2]);

	if ($#{$source_range} >= 0) {
		for my $counter (0..$#{$source_range}) {
			$#{${$data_cloud::data_stack}{$target_key}} = -1;
			${$data_cloud::data_stack}{$target_key}[0] = ${$data_cloud::data_stack}{$source_key}[${$source_range}[$counter]];
			&runner::run($program, '', 1);
		}
	} else {
		for my $counter (0..$#{${$data_cloud::data_stack}{$source_key}}) {
			$#{${$data_cloud::data_stack}{$target_key}} = -1;
			${$data_cloud::data_stack}{$target_key}[0] = ${$data_cloud::data_stack}{$source_key}[$counter];
			&runner::run($program, '', 1);
		}
	}
}

sub for {
	my $function_name = shift;
	my $arguments = shift;

	my $target_key = &variables::key(${$arguments}[0]);
	my $source_range = &variables::range_eval(${$arguments}[1]);
	my $program = &variables::value(${$arguments}[2]);

	if ($#{$source_range} >= 0) {
		for my $counter (0..$#{$source_range}) {
			$#{${$data_cloud::data_stack}{$target_key}} = -1;
			${$data_cloud::data_stack}{$target_key}[0] = "'".$counter."'";
			&runner::run($program, '', 1);
		}
	}
}



1;

