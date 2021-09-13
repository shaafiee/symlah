package variables;

my $pointer_stack;
my @output_scope;

sub unique {
	my $arguments = shift;
	foreach my $argument (@{$arguments}) {
		&data_cloud::unique(&key($argument));
	}
}

sub count {
	my $function_name = shift;
	my $arguments = shift;

	my $source_key = &key(${$arguments}[0]);
	my $source_range = &range_eval(${$arguments}[0]);
	my $count = '';
	if ($#{$source_range} >= 0) {
		$count = $#{$source_range} + 1;
	} else {
		$count = $#{${$data_cloud::data_stack}{$source_key}} + 1;
	}
	&data_cloud::assign(&key($function_name), $count, 1);
}

sub assign {
	my $function_name = shift;
	my $arguments = shift;

	my $target = shift(@{$arguments});
	my $target_range = &range_eval($target);
	my $target_key = &key($target);
	if ($#{$target_range} >= 0) {
		my $argument_counter = -1;
		my $target_counter = -1;
		while ($argument_counter < $#{$arguments}) {
			$argument_counter++;
			if (${$arguments}[$argument_counter] =~ /^\'.*\'$/) {
				$target_counter++;
				if (${$target_range}[$target_counter] > 0) {
					$target_location = ${$target_range}[$target_counter];
				} else {
					if ($#{$target_range} >= 0) {
						$target_location = ${target_range}[$#{$target_range}] + $target_counter + 1;
					} else {
						$target_location = $target_counter + 1;
					}
				}
				&data_cloud::assign($target_key, ${$arguments}[$argument_counter], $target_location);
			} else {
				my $source_range = &range_eval(${$arguments}[$argument_counter]);
				if ($#{$source_range} >= 0) {
					for my $source_counter (0..$#{$source_range}) {
						$target_counter++;
						my $target_location;
						if (${$target_range}[$target_counter] > 0) {
							$target_location = ${$target_range}[$target_counter];
						} else {
							if ($#{$target_range} >= 0) {
								$target_location = ${target_range}[$#{$target_range}] + $target_counter + 1;
							} else {
								$target_location = $target_counter + 1;
							}
						}
						my $argument_key = &key(${$arguments}[$argument_counter]);
						&data_cloud::assign($target_key, ${$data_cloud::data_stack}{$argument_key}[${$source_range}[$source_counter] - 1], $target_location);
					}
				} else {
					$target_counter++;
					my $target_location;
					if (${$target_range}[$target_counter] > 0) {
						$target_location = ${$target_range}[$target_counter];
					} else {
						if ($#{$target_range} >= 0) {
							$target_location = ${target_range}[$#{$target_range}] + $target_counter + 1;
						} else {
							$target_location = $#{${$data_cloud::data_stack}{$target_key}} + 2;
						}
					}
					&data_cloud::assign($target_key, ${$data_cloud::data_stack}{${$argument}[$argument_counter]}[0], $target_location);
				}
				if ($target_counter == $#{$target_range}) {
					last;
				}
			}
		}
	} else {
		foreach my $argument (@{$arguments}) {
			my $source_range = &range_eval($argument);
			my $argument_key = &key($argument);
			if ($#{$source_range} >= 0) {
				my $target_location;
				for my $counter (0..$#{$source_range}) {
					&data_cloud::assign($target_key, ${$data_cloud::data_stack}{$argument_key}[${$source_range}[$counter] - 1]);
				}
			} else {
				my $target_location;
				foreach my $source_value (@{${$data_cloud::data_stack}{$argument_key}}) {
					&data_cloud::assign($target_key, $source_value);
				}
			}
		}
	}
}

sub discard {
	my $function_name = shift;
	my $arguments = shift;

	&data_cloud::discard(${$arguments}[0]);
}

sub deref {
	my $target_key = shift;
	my $arguments = shift;

	$target_key =~ /^(.*?)\[([0-9]+)\ ?/;
	my $target_location = $2;
	if (length($1) > 0) {
		$target_key = $1;
	}
	my $source_key = shift(@{$arguments});
	if (length($source_key) > 0) {
		if ($target_location > 0) {
			${$pointer_location}{$target_key}[$target_location - 1] = $source_key;
		} else {
			$#{${$pointer_location}{$target_key}} = -1;
			${$pointer_location}{$target_key}[0] = $source_key;
		}
	}
}

### HELPERS #################

sub resolv_ref {
	my $arguments = shift;
	# REMEMBER: argument is used instead of key for pointer stack because the stack keys include index locations

	my $new_args;
	my $counter = -1;
	my $new_counter = -1;
	foreach my $argument (@{$arguments}) {
		if ($argument =~ /^\'/) {
			$new_counter++;
			${$new_args}[$new_counter] = $argument;
		} elsif ($argument =~ /^(.*?)\[/) {
			my $temp_key = $1;
			my $arg_range = &range_eval($argument);
			my $sequenced = 0;
			if ($arg_range =~ /[0-9]+\ +to\ +[0-9]+\ +step/) {
			} elsif ($arg_range =~ /[0-9]+\ +to\ +[0-9]+/) {
				$sequenced = 1;
			}

			if ($#{$arg_range} > 0 && sequenced == 1) {
				my $new_start = ${$arg_range}[0];
				my $new_end;
				for my $temp_count (0..$#{$arg_range}) {
					if (${$pointer_stack}{$temp_key}[${$arg_range}[$temp_count] - 1] =~ /^\'?(.+?)\'?$/) {
						$new_end = $temp_count - 1;
						$new_counter++;
						${$new_args}[$new_counter] = $temp_key."[".$new_start." to ".$new_end."]";
						$new_counter++;
						${$new_args}[$new_counter] = $1;
						$new_start = $temp_count + 1;
					}
				}
				if ($new_start < $#${$arg_range}) {
					$new_counter++;
					${$new_args}[$new_counter] = $temp_key."[".$new_start." to ".$#{$arg_range}."]";
				} elsif ($new_start == $#{$arg_range}) {
					${$new_args}[$new_counter] = $temp_key."[".$new_start."]";
				}
			} elsif ($#{$arg_range} > 0 && sequenced == 0) {
				my $location_list;
				my $first = 1;
				for my $temp_count (0..$#{$arg_range}) {
					if (${$pointer_stack}{$temp_key}[${$arg_range}[$temp_count] - 1] =~ /^\'?(.+?)\'?$/) {
						if (length($location_list) > 0) {
							$new_counter++;
							${$new_args}[$new_counter] = $temp_key."[".$location_list."]";
							$location_list = '';
						}
						$new_counter++;
						${$new_args}[$new_counter] = $1;
					} else {
						if ($first == 1) {
							$location_list = $temp_count;
							$first = 0;
						} else {
							$location_list = $location_list.",".$temp_count;
						}
					}
				}
				if (length($location_list) > 0) {
					$new_counter++;
					${$new_args}[$new_counter] = $temp_key."[".$location_list."]";
					$location_list = '';
				}
			} elsif ($#{$arg_range} == 0) {
				$new_counter++;
				${$new_args}[$new_counter] = $temp_key."[".${$arg_range}[0]."]";
			}
		} else {
			my $arg_key = &variables::key($argument);
			if ($#{${$pointer_stack}{$arg_key}} >= 0) {
				foreach my $temp_ref (@{${$pointer_stack}{$arg_key}}) {
					$new_counter++;
					$temp_ref =~ s/\'//g;
					${$new_args}[$new_counter] = $temp_ref;
				}
			} else {
				$new_counter++;
				${$new_args}[$new_counter] = $argument;
			}
		}
	}
	foreach my $new_arg (@{$new_args}) {
		&data_cloud::scope(&key($new_arg));
	}
	return $new_args;
}

sub range_eval {
	my $variable = shift;
	$variable =~ /^.*\[\ *(.*)\ *\]/;
	$range = $1;
	my @range;
	if ($range =~ /([0-9]+)\ +to\ +([0-9]+)\ +step\ +([0-9]+)/) {
		my $start = $1;
		my $end = $2;
		my $step = $3;
		my $counter = $start;
		my $range_counter = 0;
		while ($counter <= $end) {
			$range[$range_counter] = $counter;
			$range_counter++;
			$counter = $counter + $step;
		}
	} elsif ($range =~ /([0-9]+)\ +to\ +([0-9]+)/) {
		my $start = $1;
		my $end = $2;
		my $difference = $end - $start;
		for my $counter (0..$difference) {
			$range[$counter] = $counter + $start;
		}
	} elsif ($range =~ /\,/) {
		@range = split(/\s*\,\s*/, $range);
	} elsif ($range =~ /([0-9]+)/) {
		$range[0] = $1;
	} elsif ($range =~ /(\#)/) {
		$range[0] = $1;
	}
	return \@range;
}

sub key {
	my $temp_variable = shift;

	$temp_variable =~ /^([a-zA-Z]*)\[?/;
	return $1;
}

sub is_number {
	my $value = shift;

	$value =~ /\'?([0-9]+\.?[0-9]*)\'?/;
	my $number = $1;
	if (length($number) > 0) {
		return $number;
	} else {
		return '';
	}
	
}

sub value {
	my $variable = shift;
	if ($variable =~ /^\'/) {
		$variable =~ s/\'//g;
		return $variable;
	} else {
		my $source_range = &range_eval($variable);
		if ($#{$source_range} >= 0) {
			my $temp_temp = ${$data_cloud::data_stack}{&variables::key($variable)}[${$source_range}[0]];
			$temp_temp =~ s/\'//g;
			return $temp_temp;
		} else {
			my $temp_temp = ${$data_cloud::data_stack}{$variable}[0];
			$temp_temp =~ s/\'//g;
			return $temp_temp;
		}
	}
}

sub output {
	my $first = 1;
	my $result;

	#for my $counter (0..$#{${$data_cloud::data_stack}{'numbersSorted'}}) {
	#	$result = $result.$variable."=".${$data_cloud::data_stack}{'numbersSorted'}[$counter]."|";
	#}

	for my $c1 (0..$#output_scope) {
		for my $counter (0..$#{${$data_cloud::data_stack}{$output_scope[$c1]}}) {
			$result = $result.$output_scope[$c1]."=".${$data_cloud::data_stack}{$output_scope[$c1]}[$counter]."|";
		}
	}
	chop $result;
	return $result;
}

sub output_scope {
	my $function_name = shift;
	my $arguments = shift;

	$#output_scope = -1;

	foreach my $outkey (@{$arguments}) {
		push(@output_scope, &key($outkey));
	}
}

1;

