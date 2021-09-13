# Symlah VM
# Designed and developed by Mohamed Shaafiee (2009)
#
#!/usr/bin/perl

use strict;
use Math::Complex;

package symlah;

our $version = '0.0.2';
our $version_description = 'HIGHLY EXPERIMENTAL PROTOTYPE';

# Add subsystems
require 'config/config.pl';		# package 'config'
require 'listener/listener.pl';		# package 'listener'
require 'runner/runner.pl';		# package 'runner'
require 'data_cloud/data_cloud.pl';	# package 'data_cloud'
require 'filesystem/filesystem.pl';	# package 'filesystem'
require 'variables/variables.pl';	# package 'variables'
require 'function/function.pl';		# package 'function'
require 'logic/logic.pl';		# package 'logic'
require 'comparative/comparative.pl';	# package 'comparative'
require 'flow/flow.pl';			# package 'flow'
require 'math/math.pl';			# package 'math'
require 'regex/regex.pl';		# package 'regex'
require 'iterate/iterate.pl';		# package 'iterate'
require 'time/time.pl';			# package 'time'
####

# Operational processing of 'symlah' package commences
&config::parse_config;
&listener::listen;

