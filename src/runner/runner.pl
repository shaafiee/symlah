package runner;

our $program_stack;	#program stack
our $last_call_from;	#the counter location from which the last 'callif' originated
our @suspended_LFC;	#suspended 'last_call_from' program counter for the last 'callif' in
			#   the last program which invoked a 'linkif'

sub run {
	my $program = shift;	# the program to be run
	my $input_data = shift;	# the data to be passed to the program
	my $sub_call = shift;	# indicating that this was a call from another program

	if (length($input_data) > 0 && $sub_call < 1) {
		&parse_data($input_data);
	}
	$#{${$program_stack}{$program}} = -1;
	&filesystem::read_program($program);
	&execute($program);

	if ($sub_call != 1) {
	}
}

sub parse_data {
	my $temp_data = shift;

	my $last_literal;
	my $last_attribute;
	my $last_divider;
	chomp($temp_data);
	$temp_data =~ s/\s$//g;
	$temp_data = $temp_data."|some=1";
	while (length($temp_data) > 0) {
		if ($temp_data =~ s/^(.*?)([\=\(\)\|]{1})//s) {
		} else {
			last;
		}
		my $curr_literal = $1;
		my $curr_divider = $2;

			if ($curr_divider eq '=') {
			} elsif ($curr_divider eq '|') {
				if ($last_divider eq '=') {
					if ($curr_literal eq '!') {
						&data_cloud::discard($last_literal);
					} else {
						&data_cloud::assign($last_literal, $curr_literal);
					}
					$last_attribute = $last_literal;
				} elsif ($last_divider eq '(') {
					if (length($last_attribute) <= 0) {
						${$assoc_stack}{$last_literal} = $curr_literal;
					} else {
						${$assoc_stack}{$last_attribute} = $curr_literal;
					}
				} else {
				}
			} elsif ($curr_divider eq ')') {
				if ($last_divider eq '=') {
					if ($curr_literal eq '!') {
						&data_cloud::discard($last_literal);
					} else {
						&data_cloud::assign($last_literal, $curr_literal);
					}
					$last_attribute = $last_literal;
				} elsif ($last_divider eq '(') {
					if (length($last_attribute) <= 0) {
						${$assoc_stack}{$last_literal} = $curr_literal;
					} else {
						${$assoc_stack}{$last_attribute} = $curr_literal;
					}
				} elsif ($last_divider eq '|') {
					if (length($last_attribute) <= 0) {
						${$assoc_stack}{$last_literal} = $curr_literal;
					} else {
						${$assoc_stack}{$last_attribute} = $curr_literal;
					}
				}
			} elsif ($curr_divider eq '(') {
				if ($last_divider eq '=') {
					if ($curr_literal eq '!') {
						&data_cloud::discard($last_literal);
					} else {
						&data_cloud::assign($last_literal, $curr_literal);
					}
					$last_attribute = $last_literal;
				} elsif ($last_divider eq '|') {
				} elsif ($last_divider eq ')') {
				}
			} else {
			}
			$last_literal = $curr_literal;
			$last_divider = $curr_divider;
	}
}

sub execute {
	my $program = shift;

	my $program_counter = -1;

	while ($program_counter < $#{${$program_stack}{$program}}) {
		$program_counter++;
		my $statement = ${$program_stack}{$program}[$program_counter];
		$statement =~ s/(a-zA-Z0-9)*?\s*?(\<.*)/$1$2/;
		$statement =~ /^\s*?([a-zA-Z0-9\[\]]*)\</;
		my $function_name = $1;
		&data_cloud::scope(&variables::key($function_name));
		my $temp_arguments = &function::dissect($statement);
		my $function = shift(@{$temp_arguments});

		if ($function eq 'count') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&variables::count($function_name, $arguments);
		} elsif ($function eq 'assign') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&variables::assign($function_name, $arguments);
		} elsif ($function eq 'discard') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&variables::discard($function_name, $arguments);
		} elsif ($function eq 'deref') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&variables::deref($function_name, $arguments);
		} elsif ($function eq 'unique') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&variables::unique($arguments);
		} elsif ($function eq 'not') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&logic::not($function_name, $arguments);
		} elsif ($function eq 'and') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&logic::and($function_name, $arguments);
		} elsif ($function eq 'or') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&logic::or($function_name, $arguments);
		} elsif ($function eq 'equal') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&comparative::equal($function_name, $arguments);
		} elsif ($function eq 'greater') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&comparative::greater($function_name, $arguments);
		} elsif ($function eq 'less') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&comparative::less($function_name, $arguments);
		} elsif ($function eq 'greaterorequal') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&comparative::greater_or_equal($function_name, $arguments);
		} elsif ($function eq 'lessorequal') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&comparative::less_or_equal($function_name, $arguments);
		} elsif ($function eq 'callif') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			my $temp_count = &flow::callif($program, $function_name, $arguments);
			if ($temp_count >= 0) {
				$last_call_from = $program_counter;
				$program_counter = $temp_count;
			}
		} elsif ($function eq 'return') {
			if ($last_call_from >= 0) {
				$program_counter = $last_call_from;
				$last_call_from = '';
			}
		} elsif ($function eq 'linkif') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			my $suspended_token = &data_cloud::suspend_unique();
			unshift(@suspended_LFC, $last_call_from);
			&flow::linkif($function_name, $arguments);
			$last_call_from = shift @suspended_LFC;
			&data_cloud::revive_unique($suspended_token);
		} elsif ($function eq 'exit') {
			last;
		} elsif ($function eq 'add') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&math::add($function_name, $arguments);
		} elsif ($function eq 'subtract') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&math::subtract($function_name, $arguments);
		} elsif ($function eq 'multiply') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&math::multiply($function_name, $arguments);
		} elsif ($function eq 'divide') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&math::divide($function_name, $arguments);
		} elsif ($function eq 'mod') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&math::mod($function_name, $arguments);
		} elsif ($function eq 'squareroot') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&math::squareroot($function_name, $arguments);
		} elsif ($function eq 'match') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&regex::match($function_name, $arguments);
		} elsif ($function eq 'substitute') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&regex::substitute($function_name, $arguments);
		} elsif ($function eq 'split') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&regex::split($function_name, $arguments);
		} elsif ($function eq 'last') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&regex::last($function_name);
		} elsif ($function eq 'foreach') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			my $suspended_token = &data_cloud::suspend_unique();
			&iterate::foreach($function_name, $arguments);
			&data_cloud::revive_unique($suspended_token);
		} elsif ($function eq 'for') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			my $suspended_token = &data_cloud::suspend_unique();
			&iterate::for($function_name, $arguments);
			&data_cloud::revive_unique($suspended_token);
		} elsif ($function eq 'whence') {
			 &time::whence($function_name);
		} elsif ($function eq 'now') {
			 &time::now($function_name);
		} elsif ($function eq 'output') {
			my $arguments = &variables::resolv_ref($temp_arguments);
			&variables::output_scope($function_name, $arguments);
		}
	}
	&data_cloud::close_unique;
}

sub log {
	my $line = shift;
	open (LOG, ">>".$config::directive{'svm_dir'}."/symlah.log");
	print LOG $line."\n";
	close(LOG);
}

1;

