package logic;

sub not {
	my $function_name = shift;
	my $arguments = shift;

	my $target_key = &variables::key($function_name);
	my $source_key = &variables::key(${$arguments}[0]);
	my $target_range = &variables::range_eval($function_name);
	my $source_range = &variables::range_eval($source_key);

	my $counter = -1;
	if ($#{$source_range} >= 1 || $#{$source_range} < 0) {
		foreach my $source_value (@{${$data_cloud::data_stack}{$source_key}}) {
			$counter++;
			my $not_result;
			if (length($source_value) > 0) {
				$not_result = '';
			} else {
				$not_result = '1';
			}
			if ($#{$target_range} >= 0) {
				if (${$target_range}[$counter] >= 0) {
					&data_cloud::assign($target_key, $not_result, ${$target_range}[$counter]);
				} else {
					last;
				}
			} else {
				&data_cloud::assign($target_key, $not_result);
			}
		}
	} else {
		$counter++;
		if (length(${$data_cloud::data_stack}{$source_key}[${$source_range}[0]]) > 0) {
			$not_result = '';
		} else {
			$not_result = 1;
		}
		if ($#{$target_range} >= 0) {
			&data_cloud::assign($target_key, $not_result, ${$target_range}[0]);
		} else {
			&data_cloud::assign($target_key, $not_result);
		}
	}
}

sub and {
	my $function_name = shift;
	my $arguments = shift;

	my $target_key = &variables::key($function_name);
	my $target_range = &variables::range_eval($function_name);

	my $max_count = 0;
	if ($#{$arguments} > 0) {
		foreach my $argument (@{$arguments}) {
			if ($#{${$data_cloud::data_stack}{&variables::key($argument)}} > $max_count) {
				$max_count = $#{${$data_cloud::data_stack}{&variables::key($argument)}};
			}
		}

		my $target_counter = 0;
		for my $counter (0..$max_count) {
			my $and_result = 1;
			foreach my $argument (@{$arguments}) {
				if (length(${$data_cloud::data_stack}{&variables::key($argument)}[$counter]) <= 0) {
					$and_result = '';
				}
			}
			if ($#{$target_range} >= 0) {
				if (${$target_range}[$target_counter] == $counter + 1) {
					&data_cloud::assign($target_key, $and_result, ${$target_range}[$target_counter]);
					$target_counter++;
				}
			} else {
				&data_cloud::assign($target_key, $and_result);
				$target_counter++;
			}
		}
	} else {
		my $and_result = 1;
		foreach my $source_value (@{${$data_cloud::data_stack}{&variables::key(${$arguments}[0])}}) {
			if (length($source_value) <= 0) {
				$and_result = '';
			}
		}
		if ($#{$target_range} >= 0) {
			&data_cloud::assign($target_key, $and_result, ${$target_range}[0]);
		} else {
			&data_cloud::assign($target_key, $and_result, 1);
		}
	}
}

sub or {
	my $function_name = shift;
	my $arguments = shift;

	my $target_key = &variables::key($function_name);
	my $target_range = &variables::range_eval($function_name);

	my $max_count = 0;
	if ($#{$arguments} > 0) {
		foreach my $argument (@{$arguments}) {
			if ($#{${$data_cloud::data_stack}{&variables::key($argument)}} > $max_count) {
				$max_count = $#{${$data_cloud::data_stack}{&variables::key($argument)}};
			}
		}

		my $target_counter = 0;
		for my $counter (0..$max_count) {
			my $or_result = '';
			foreach my $argument (@{$arguments}) {
				if (length(${$data_cloud::data_stack}{&variables::key($argument)}[$counter]) > 0) {
					$or_result = 1;
				}
			}
			if ($#{$target_range} >= 0) {
				if (${$target_range}[$target_counter] == $counter + 1) {
					&data_cloud::assign($target_key, $or_result, ${$target_range}[$target_counter]);
					$target_counter++;
				}
			} else {
				&data_cloud::assign($target_key, $or_result);
				$target_counter++;
			}
		}
	} else {
		my $or_result = '';
		foreach my $source_value (@{${$data_cloud::data_stack}{&variables::key(${$arguments}[0])}}) {
			if (length($source_value) > 0) {
				$or_result = 1;
			}
		}
		if ($#{$target_range} >= 0) {
			&data_cloud::assign($target_key, $or_result, ${$target_range}[0]);
		} else {
			&data_cloud::assign($target_key, $or_result, 1);
		}
	}
}

1;


