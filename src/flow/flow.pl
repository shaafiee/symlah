package flow;

sub callif {
	my $program = shift;
	my $function_name = shift;
	my $arguments = shift;

	my $pivot = &variables::value(${$arguments}[0]);
	my $target_function = &variables::value(${$arguments}[1]);
	my $alternative_function;
	if (length(${$arguments}[2]) > 0) {
		$alternative_function = &variables::value(${$arguments}[2]);
	}

	if (length($pivot) > 0) {
		if (length($target_function) > 0) {
			return &function_location($program, $target_function);
		}
	} else {
		if (length($alternative_function) > 0) {
			return &function_location($program, $alternative_function);
		} else {
			return -1;
		}
	}
}

sub linkif {
	my $function_name = shift;
	my $arguments = shift;

	my $pivot = &variables::value(${$arguments}[0]);
	my $program_to_run = &variables::value(${$arguments}[1]);
	my $alternative_program;
	if (length(${$arguments}[2]) > 0) {
		$alternative_program = &variables::value(${$arguments}[2]);
	}

	if (length($pivot) > 0) {
		if (length($program_to_run) > 0) {
			&runner::run($program_to_run, '', 1);
		}
	} else {
		if (length($alternative_program) > 0) {
			&runner::run($alternative_program, '', 1);
		}
	}
}

sub function_location {
	my $program = shift;
	my $function_queried = shift;

	$function_queried =~ s/\'//g;
	my $found = -1;
	for my $counter (0..$#{${$runner::program_stack}{$program}}) {
		if (${$runner::program_stack}{$program}[$counter] =~ /^\s*?$function_queried/) {
			$found = $counter - 1;
			last;
		}
	}
	return $found;
}

1;

