package function;

sub dissect {
	my $statement = shift;

	$statement =~ /\<(.*)\>/;
	my $temp_rest = $1." ";

	my @arguments;

	my $lit_open = 0;
	my $counter = -1;
	while ($temp_rest =~ s/^(.*?)(\ +)//) {
		my $temp_val = $1;
		my $separator = $2;
		if ($lit_open == 0) {
			$counter++;
		}
		if ($lit_open == 1) {
			if ($temp_val =~ /\'$/) {
				$lit_open = 0;
			}
			$arguments[$counter] = $arguments[$counter].$temp_val.$separator;
		} else {
			if ($temp_val =~ /^\'.*\'/) {
				$arguments[$counter] = $temp_val;
			} elsif ($temp_val =~ /^\'/) {
				$lit_open = 1;
				$arguments[$counter] = $arguments[$counter].$temp_val.$separator;
			} else {
				$arguments[$counter] = $temp_val;
			}
		}
	}

	return \@arguments;
}

1;

