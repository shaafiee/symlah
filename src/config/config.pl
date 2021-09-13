package config;

our %directive;

sub parse_config {
	open(CONFIG_FILE, "</etc/svm.conf") || die "Error opening file!\n";
	while (my $config_line = <CONFIG_FILE>) {
		if ($config_line =~ /^\#.*$/) {
		} elsif ($config_line =~ /^\s.*$/) {
		} else {
			$config_line =~ /^\s*?([a-z\_]+)\s+?([a-zA-Z0-9\/]+)/;
			if (	$1 eq 'svm_dir' ||
				$1 eq 'svm_data' ||
				$1 eq 'svm_port') {
				$directive{$1} = $2;
			}
		}
	}
	close(CONFIG_FILE);

	if (	length($directive{'svm_dir'}) <= 0 ||
		length($directive{'svm_data'}) <= 0 ||
		! ($directive{'svm_port'} =~ /^[0-9]{2,5}$/) ) {
		print "Incomplete '/etc/svm.conf' configuration.\n";
		exit 0;
	}

	if (length($directive{'svm_port'}) <= 0) {
		$directive{'svm_port'} = 10115;
	}
}

1;

