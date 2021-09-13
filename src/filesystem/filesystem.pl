package filesystem;

sub read_data {
	my $temp_variable = shift;
	if (&check_file($config::directive{'svm_data'}, $temp_variable)) {
		open(DATA_FILE, "<".$config::directive{'svm_data'}."/".$temp_variable) || die "Error opening data file $temp_variable";
		while (my $value_read = <DATA_FILE>) {
			${$data_cloud::data_stack}{$key}[$#{${$data_cloud::data_stack}{$key}} + 1] = $value_read;
		}
		close(DATA_FILE);
	}
}

sub write_data {
	my $temp_variable = shift;
	my $temp_value = shift;
	my $temp_location = shift;

	chomp $temp_value;
	if ($temp_location > 0) {
		if (&check_file($config::directive{'svm_data'}, $temp_variable) == 1) {
			open(SWAP_FILE, ">".$config::directive{'svm_data'}."/".$temp_variable.".swp") || die "Error opening data file $temp_variable.swp";
			open(DATA_FILE, $config::directive{'svm_data'}."/".$temp_variable) || die "Error opening data file $temp_variable";
			my $counter = 1;
			while (my $value_read = <DATA_FILE>) {
				if ($counter eq $temp_location) {
					print SWAP_FILE $temp_value."\n";
				} else {
					print SWAP_FILE $value_read."\n";
				}
				$counter++;
			}
			close(DATA_FILE);
			close(SWAP_FILE);
			rename($config::directive{'svm_data'}."/".$temp_variable.".swp", $config::directive{'svm_data'}."/".$temp_variable);
		} else {
			open(DATA_FILE, ">".$config::directive{'svm_data'}."/".$temp_variable) || die "Error opening data file $temp_variable";
			print DATA_FILE $temp_value."\n";
			close(DATA_FILE);
		}
	} else {
		open(DATA_FILE, ">>".$config::directive{'svm_data'}."/".$temp_variable) || die "Error opening data file $temp_variable";
		print DATA_FILE $temp_value."\n";
		close(DATA_FILE);
	}
}

sub discard {
	my $temp_variable = shift;
	my $range = shift;

	if (&check_file($config::directive{'svm_data'}, $temp_variable) == 1) {
	} else {
		return;
	}

	if ($#{$range} >= 0) {
		open(SWAP_FILE, ">".$config::directive{'svm_data'}."/".$temp_variable.".swp") || die "Error opening data file $temp_variable";
		open(DATA_FILE, $config::directive{'svm_data'}."/".$temp_variable) || die "Error opening data file $temp_variable";
		my $counter = 1;
		my $range_counter = 0;
		while (my $value_read = <DATA_FILE>) {
			if ($counter eq ${$range}[$range_counter]) {
				$range_counter++;
			} else {
				print SWAP_FILE $value_read;
			}
			$counter++;
		}
		
		close(DATA_FILE);
		close(SWAP_FILE);
		rename($config::directive{'svm_data'}."/".$temp_variable.".swp", $config::directive{'svm_data'}."/".$temp_variable);
	} else {
		unlink($config::directive{'svm_data'}."/".$temp_variable);
		#open(DATA_FILE, ">".$config::directive{'svm_data'}."/".$temp_variable) || die "Error opening data file $temp_variable";
		#close(DATA_FILE);
	}
}

sub read_program {
	my $program_name = shift;
	my $temp_program;
	my $pre_dir = '';
	if ($program_name =~ /\//) {
		my @splits = split(/\//, $program_name);
		for my $counter (0..($#splits - 1)) {
			$pre_dir = $pre_dir."/".$splits[$counter];
		}
		$temp_program = $splits[$#splits];
	} else {
		$temp_program = $program_name;
	}
	if (&check_file($config::directive{'svm_dir'}.$pre_dir, $temp_program)) {
		open(PROGRAM_FILE, "<".$config::directive{'svm_dir'}.$pre_dir."/".$temp_program) || die "Error opening data file $temp_variable";
		my $counter = -1;
		while (my $value_read = <PROGRAM_FILE>) {
			chomp $value_read;
			if ($value_read =~ /^\s*$/) {
			} else {
				$counter++;
				${$runner::program_stack}{$program_name}[$counter] = $value_read;
			}
		}
		$#{${$runner::program_stack}{$program_name}} = $counter;
		close(PROGRAM_FILE);
	}
}

sub check_file {
        my $directory = shift;
        my $filename = shift;
        opendir(DIR, $directory);
        @list = grep { !/^\.*$/ && /^$filename$/i } readdir(DIR);
        closedir DIR;
        if ($#list >= 0) {
                return 1;
        } else {
                return '';
        }
}

1;

