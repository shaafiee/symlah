package data_cloud;

our $data_stack;
our $suspended_stack;
our $assoc_stack;
our $unique_stack;
our $suspended_count;
our $suspended_list;

sub unique {
	my $key = shift;
	${$unique_stack}{$key} = 1;
}

sub scope {
	my $key = shift;

	if (${$unique_stack}{$key} != 1) {
		if ($#{${$data_stack}{$key}} < 0) {
			&filesystem::read_data($key);
		}
	}
}

sub suspend_unique {
	$suspended_count++;
	foreach my $unique (keys(%{$unique_stack})) {
		@{${${$suspended_stack}{$suspended_count}}{$unique}} = @{${$data_stack}{$unique}};
		@{${$data_stack}{$unique}} = ();
	}
	%{$unique_stack} = ();
	return $suspended_count;
}

sub revive_unique {
	my $suspended_token = shift;
	foreach my $unique (keys(%{${$suspended_stack}{$suspended_token}})) {
		${$unique_stack}{$unique} = 1;
		@{${$data_stack}{$unique}} = @{${$suspended_stack}{$suspended_token}{$unique}};
	}
}

sub close_unique {
	foreach my $unique (keys(%{$unique_stack})) {
		@{${$data_stack}{$unique}} = ();
	}
	%{$unique_stack} = ();
}

sub assign {
	my $key = shift;
	my $value = shift;
	my $key_location = shift;

	if ($key_location > 0) {
		${$data_stack}{$key}[$key_location - 1] = $value;
	} else {
		push(@{${$data_stack}{$key}}, ($value));
	}
	if (${$unique_stack}{$key} != 1) {
		&filesystem::write_data($key, $value, $key_location);
	}
}

sub discard {
	my $variable = shift;

	my $sequenced;
	if ($variable =~ /^.+\[\ *([0-9]+)\ +to\ +([0-9]+)\ *\]$/) {
                $sequenced = 1;
        }
        my $key = &variables::key($variable);
        my $range = &variables::range_eval($variable);

	if ($#{$range} >= 0) {
		if ($sequenced == 1) {
			splice(@{${$data_stack}{$key}}, (${$range}[0] - 1), ${$range}[$#{$range}] - ${$range}[0]);
		} else {
			foreach my $range_item (@{$range}) {
				splice(@{${$data_stack}{$key}}, $range_item - 1, 1);
			}
		}
		if (${$unique_stack}{$key} != 1) {
			&filesystem::discard($key, $range);
		}
	} else {
		@{${$data_stack}{$key}} = ();
		$#{${$data_stack}{$key}} = -1;
		#  splice @{${$data_stack}{$key}};
		#  $#{${$data_stack}{$key}} = -1;
		if (${$unique_stack}{$key} != 1) {
			&filesystem::discard($key);
		}
	}
}

1;

