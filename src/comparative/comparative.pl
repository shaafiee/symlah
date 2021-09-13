package comparative;

sub equal {
	my $function_name = shift;
	my $arguments = shift;

	&iterator($function_name, $arguments, 'equal');
}

sub greater {
	my $function_name = shift;
	my $arguments = shift;

	&iterator($function_name, $arguments, 'greater');
}

sub less {
	my $function_name = shift;
	my $arguments = shift;

	&iterator($function_name, $arguments, 'less');
}

sub greater_or_equal {
	my $function_name = shift;
	my $arguments = shift;

	&iterator($function_name, $arguments, 'greater_or_equal');
}

sub less_or_equal {
	my $function_name = shift;
	my $arguments = shift;

	&iterator($function_name, $arguments, 'less_or_equal');
}

sub iterator {
	my $function_name = shift;
	my $arguments = shift;
	my $operator = shift;

	my $target_key = &variables::key($function_name);
	my $target_range = &variables::range_eval($function_name);
	my $pivot_key = &variables::key(${$arguments}[0]);
	my $pivot_range = &variables::range_eval(${$arguments}[0]);
	my $source_key = &variables::key(${$arguments}[1]);
	my $source_range = &variables::range_eval(${$arguments}[1]);

	my $pivot;
	if ($#{$pivot_range} >= 0) {
		$pivot = ${$data_cloud::data_stack}{$pivot_key}[${$pivot_range}[0]];
	} else {
		$pivot = ${$data_cloud::data_stack}{$pivot_key}[0];
	}

	my @results;
	if ($#{$source_range} > -1) {
		foreach my $source_index (@{$source_range}) {
			if (&compare($pivot, ${$data_cloud::data_stack}{$source_key}[$source_index - 1], $operator) == 1) {
				$results[$#results + 1] = $source_key."[".$source_index."]";
			}
		}
	} else {
		if (${$arguments}[1] =~ /^\'/) {
			if (&compare($pivot, &variables::value(${$arguments}[1]), $operator) == 1) {
				$results[$#results + 1] = "1";
			}
		} else {
			for my $source_index (0..$#{${$data_cloud::data_stack}{$source_key}}) {
				if (&compare($pivot, ${$data_cloud::data_stack}{$source_key}[source_index], $operator) == 1) {
					$results[$#results + 1] = $source_key."[".($source_index + 1)."]";
				}
			}
		}
	}
	$#{${$data_cloud::data_stack}{$target_key}} = -1;
	@{${$data_cloud::data_stack}{$target_key}} = @results;
}

sub compare {
	my $first = shift;
	my $second = shift;
	my $operator = shift;
	if ($operator eq 'equal') {
		if (&both_numbers($first, $second)) {
			if ($first == $second) {
				return 1;
			} else {
				return '';
			}
		} else {
			if ($first eq $second) {
				return 1;
			} else {
				return '';
			}
		}
	} elsif ($operator eq 'greater') {
		if (&both_numbers($first, $second)) {
			if ($first > $second) {
				return 1;
			} else {
				return '';
			}
		} else {
			if ($first gt $second) {
				return 1;
			} else {
				return '';
			}
		}
	} elsif ($operator eq 'less') {
		if (&both_numbers($first, $second)) {
			if ($first < $second) {
				return 1;
			} else {
				return '';
			}
		} else {
			if ($first lt $second) {
				return 1;
			} else {
				return '';
			}
		}
	} elsif ($operator eq 'greater_or_equal') {
		if (&both_numbers($first, $second)) {
			if ($first >= $second) {
				return 1;
			} else {
				return '';
			}
		} else {
			if ($first ge $second) {
				return 1;
			} else {
				return '';
			}
		}
	} elsif ($operator eq 'less_or_equal') {
		if (&both_numbers($first, $second)) {
			if ($first <= $second) {
				return 1;
			} else {
				return '';
			}
		} else {
			if ($first le $second) {
				return 1;
			} else {
				return '';
			}
		}
	}
}

sub both_numbers {
	my $first = shift;
	my $second = shift;
	my $both = 0;
	if (&variables::is_number($first)) {
		$both++;
	}
	if (&variables::is_number($second)) {
		$both++;
	}
	if ($both == 2) {
		return 1;
	} else {
		return '';
	}
}

1;

