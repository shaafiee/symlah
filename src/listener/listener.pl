package listener;

use Socket;
use URI::Escape;
use IO::Handle;

sub listen {
	my $port = $config::directive{'svm_port'};
	my $protocol = getprotobyname('tcp');

	socket(MYSOCK, PF_INET, SOCK_STREAM, $protocol) || die "Uh-oh, $!";
	setsockopt(MYSOCK, SOL_SOCKET, SO_REUSEADDR, pack("l", 1)) || die "$!";
	bind(MYSOCK, sockaddr_in($port, INADDR_ANY)) || die "$!";
	listen(MYSOCK, SOMAXCONN);

	my $paddr;
	my $iaddr;


	for (; $paddr = accept(CLIENTSOCK, MYSOCK); close CLIENTSOCK) {
		CLIENTSOCK->autoflush();
		my ($port, $iaddr) = sockaddr_in($paddr);
		my $name = gethostbyaddr($iaddr, AF_INET);
		print CLIENTSOCK "SVM: Symlah VM version ".$symlah::version." (".$symlah::version_description.")\n";
		print CLIENTSOCK ">";
		while ($all_input = <CLIENTSOCK>) {
			if ($all_input =~ /^quit/) {
				print CLIENTSOCK "SVM: Thank you. Goodbye.\n";
				last;
			} elsif ($all_input =~ /^run\ {1}(\S+)\ {1}(.+)$/) {
				if (&validate_program_name($1) && &validate_data($2)) {
					&runner::run($1, $2);
					my $output = &variables::output;
					print CLIENTSOCK $output."\n";
				}
			} elsif ($all_input =~ /^run/) {
				print CLIENTSOCK "SVM: The correct format for 'run' is:\n";
				print CLIENTSOCK "SVM:       run <program_name> <data>\n";
			} else {
				print CLIENTSOCK "SVM: Incorrect command.\n";
			}
			print CLIENTSOCK ">";
		}
	}
}

sub validate_program_name {
	# TO BE IMPLEMENTED!!!
	return 1;
}

sub validate_data {
	# TO BE IMPLEMENTED!!!
	return 1;
}

1;

