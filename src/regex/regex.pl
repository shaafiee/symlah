package regex;

our @last_matched;

sub match {
	my $function_name = shift;
	my $arguments = shift;

	&iterator($function_name, $arguments, 'match');
}

sub substitute {
	my $function_name = shift;
	my $arguments = shift;

	&iterator($function_name, $arguments, 'substitute');
}

sub split {
	my $function_name = shift;
	my $arguments = shift;

	&iterator($function_name, $arguments, 'split');
}

sub last {
	my $function_name = shift;
	my $target_key = &variables::key($function_name);

	$#{${$data_cloud::data_source}{$target_key}} = -1;
	@{${$data_cloud::data_source}{$target_key}} = @last_matched;
}

sub iterator {
	my $function_name = shift;
	my $arguments = shift;
	my $todo = shift;

	if ($#{$arguments} != 1) {
		return;
	}
	my $target_key = &variables::key($function_name);
	$#{${$data_cloud::data_source}{$target_key}} = -1;

	my $reg_key = &variables::key(${$arguments}[1]);
	my $regex = &variables::value($reg_key);

	my $source_key = &variables::key(${$arguments}[0]);
	my $source_range = &variables::range_eval(${$arguments}[0]);

	my $target_location = -1;
	if ($#{$source_range} >= 0) {
		foreach my $source_location (@{$source_range}) {
			my $results = &operate(${$data_cloud::data_source}{$source_key}[$source_location - 1], $regex, $todo);
			if ($todo eq 'match') {
				if (${$results}[1] == 1) {
					$target_location++;
					${$data_cloud::data_source}{$target_key}[$target_location] = "'".$source_key."[".$source_location."]";
				}
			} elsif ($todo eq 'split') {
				foreach my $result (@{$results}) {
					$target_location++;
					${$data_cloud::data_source}{$target_key}[$target_location] = $result;
				}
			}
		}
	} else {
		if (${$arguments}[0] =~ /^\'/) {
			my $results = &operate(&variables::value(${$arguments}[0]), $regex, $todo);
			@{${$data_cloud::data_source}{$target_key}} = @{$result};
		} else {
			foreach my $source_location (0..$#{${$data_cloud::data_stack}{$source_key}}) {
				my $results = &operate(${$data_cloud::data_source}{$source_key}[$source_location], $regex, $todo);
				if ($todo eq 'match') {
					if (${$results}[1] == 1) {
						$target_location++;
						${$data_cloud::data_source}{$target_key}[$target_location] = "'".$source_key."[".$source_location."]";
					}
				} elsif ($todo eq 'split') {
					foreach my $result (@{$results}) {
						$target_location++;
						${$data_cloud::data_source}{$target_key}[$target_location] = $result;
					}
				}
			}
		}
	}
}

sub operate {
	my $first = shift;
	my $regex = shift;
	my $todo = shift;

	my @results;
	if ($todo eq 'match') {
		$regex =~ s/^\///;
		$regex =~ s/\/$//;
		if ($first =~ /$regex/) {
			my $current;
			for my $counter (1..100) {
				$current = '';
				eval("$current = \$".$counter);
				if (length($current) > 0) {
					$last_matched[$#last_matched + 1] = $current;
				} else {
					last;
				}
			}
			$results[0] = 1;
			return \@results;
		} else {
			return '';
		}
	} elsif ($todo eq 'substitute') {
		eval("\$first =~ ".$regex);
		my $current;
		for my $counter (1..100) {
			$current = '';
			eval("$current = \$".$counter);
			if (length($current) > 0) {
				$last_matched[$#last_matched + 1] = $current;
			} else {
				last;
			}
		}
		return '';
	} elsif ($todo eq 'split') {
		@results = split($regex, $first);
		for my $counter (0..$#results) {
			$results[$counter] = "'".$results[$counter]."'";
		}
		return \@results;
	}
}

1;

