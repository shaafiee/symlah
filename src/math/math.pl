package math;

sub add {
	my $function_name = shift;
	my $arguments = shift;

	my $totals;
	if ($#{$arguments} == 0) {
		$totals = &linear_iterator($arguments, 'add');
	} elsif ($#{$arguments} > 0) {
		$totals = &iterator($arguments, 'add');
	} else {
		return;
	}
	&assign_totals($function_name, $totals);
}

sub subtract {
	my $function_name = shift;
	my $arguments = shift;

	my $totals;
	if ($#{$arguments} == 0) {
		$totals = &linear_iterator($arguments, 'subtract');
	} elsif ($#{$arguments} > 0) {
		$totals = &iterator($arguments, 'subtract');
	} else {
		return;
	}
	&assign_totals($function_name, $totals);
}

sub multiply {
	my $function_name = shift;
	my $arguments = shift;

	my $totals;
	if ($#{$arguments} == 0) {
		$totals = &linear_iterator($arguments, 'multiply');
	} elsif ($#{$arguments} > 0) {
		$totals = &iterator($arguments, 'multiply');
	} else {
		return;
	}
	&assign_totals($function_name, $totals);
}

sub divide {
	my $function_name = shift;
	my $arguments = shift;

	my $totals;
	if ($#{$arguments} == 0) {
		$totals = &linear_iterator($arguments, 'divide');
	} elsif ($#{$arguments} > 0) {
		$totals = &iterator($arguments, 'divide');
	} else {
		return;
	}
	&assign_totals($function_name, $totals);
}

sub mod {
	my $function_name = shift;
	my $arguments = shift;

	if ($#{$arguments} != 1) {
		return;
	}
	my $totals = &iterator($arguments, 'mod');
	&assign_totals($function_name, $totals);
}

sub squareroot {
	my $function_name = shift;
	my $arguments = shift;

	if ($#{$arguments} != 0) {
		return;
	}
	my $totals = &linear_iterator($arguments, 'squareroot');
	&assign_totals($function_name, $totals);
}

sub iterator {
	my $arguments = shift;
	my $todo = shift;

	my @totals;
	my %range;
	my $max_count;
	foreach my $argument (@{$arguments}) {
		my $cur_key = &variables::key($argument);
		$range{$cur_key} = &variables::range_eval($argument);
		if ($#{$range{$cur_key}} >= 0) {
			if ($#{$range{$argument}} > $max_count) {
				$max_count = $#{$range{$cur_key}};
			}
		} else {
			if ($#{${$data_cloud::data_stack}{$key{$argument}}} > $max_count) {
				$max_count = $#{${$data_cloud::data_stack}{$cur_key}};
			}
		}
	}
	for my $counter (0..$max_count) {
		foreach my $argument (@{$arguments}) {
			my $cur_key = &variables::key($argument);
			if ($#{$range{$cur_key}} >= 0) {
				if ($counter <= $#{$range{$cur_key}}) {
					if (length($totals[$counter]) == 0) {
						$totals[$counter] = ${$data_cloud::data_stack}{$cur_key}[$range{$cur_key}[$counter]];
					} else {
						&operate($totals[$counter], ${$data_cloud::data_stack}{$cur_key}[$range{$cur_key}[$counter]], $todo);
					}
				}
			} else {
				if ($argument =~ /^\'/) {
					if (length($totals[$counter]) == 0) {
						$totals[$counter] = &variables::value($argument);
					} else {
						&operate($totals[$counter], &variables::value($argument), $todo);
					}
				} else {
					if (length($totals[$counter]) == 0) {
						$totals[$counter] = ${$data_cloud::data_stack}{$cur_key}[$counter];
					} else {
						&operate($totals[$counter], ${$data_cloud::data_stack}{$cur_key}[$counter], $todo);
					}
				}
			}
		}
	}
	return \@totals;
}

sub linear_iterator {
	my $arguments = shift;
	my $todo = shift;

	my @results;
	my $source_key = &variables::key(${$arguments}[0]);
	my $source_range = &variables::range_eval(${$arguments}[0]);

	my $all_totals;
	my $totals;
	if ($#{$source_range} >= 0) {
		foreach my $counter (0..$#{$source_range}) {
			my $current_value = ${$data_cloud::data_stack}{$source_key}[${$source_range}[$counter] - 1];
			if (length($totals) <= 0) {
				$totals = $current_value;
			} else {
				$totals = &operate($totals, $current_value, $todo);
			}
		}
	} else {
		if (${$arguments}[0] =~ /^\'/) {
			if (length($totals) <= 0) {
				$totals = $current_value;
			} else {
				$totals = &operate($totals, &variables::value(${$arguments}[0]), $todo);
			}
		} else {
			foreach my $counter (0..$#{${$data_cloud::data_stack}{$source_key}}) {
				my $current_value = ${$data_cloud::data_stack}{$source_key}[$counter];
				if (length($totals) <= 0) {
					$totals = $current_value;
				} else {
					$totals = &operate($totals, $current_value, $todo);
				}
			}
		}
	}
	${$all_totals}[0] = $totals;
	return $all_totals;
}

sub assign_totals {
	my $function_name = shift;
	my $totals = shift;

	my $target_key = &variables::key($function_name);
	my $target_range = &variables::range_eval($function_name);

	if ($#{$target_range} >= 0) {
		my $total_counter = -1;
		foreach my $target_location (@{$target_range}) {
			$total_counter++;
			if (length(${$totals}[$total_counter]) > 0) {
				&data_cloud::assign($target_key, "'".${$totals}[$total_counter]."'", $target_location);
			}
		}
	} else {
		$target_location = 0;
		foreach my $total (@{$totals}) {
			$target_location++;
			&data_cloud::assign($target_key, "'".$total."'", $target_location);
		}
	}
}

sub operate {
	my $first = shift;
	my $second = shift;
	my $todo = shift;

	if ($todo eq 'add') {
		if (&both_numbers($first, $second)) {
			return ($first + $second);
		} else {
			return $first.$second;
		}
	} elsif ($todo eq 'multiply') {
		if (&both_numbers($first, $second)) {
			return ($first * $second);
		}
	} elsif ($todo eq 'divide') {
		if (&both_numbers($first, $second)) {
			if (&variables::value($first) > 0 && &variables::value($second) > 0) {
				return ($first / $second);
			}
		}
	} elsif ($todo eq 'subtract') {
		if (&both_numbers($first, $second)) {
			return ($first - $second);
		}
	} elsif ($todo eq 'mod') {
		if (&both_numbers($first, $second)) {
			return ($first % $second);
		}
	} elsif ($todo eq 'squareroot') {
		if (&variables::is_number($first)) {
			return sqrt($first);
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

