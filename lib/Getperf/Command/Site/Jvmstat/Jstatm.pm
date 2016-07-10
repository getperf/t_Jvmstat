package Getperf::Command::Site::Jvmstat::Jstatm;
use strict;
use warnings;
use Data::Dumper;
use Path::Class;
use YAML::Tiny;
use Time::Piece;
use base qw(Getperf::Container);
use Getperf::Command::Master::Jvmstat;
use Getperf::Container qw/sumup/;

sub new {
	bless{},+shift
}

sub read_java_vm_list {
    my ($self, $data_info) = @_;

    my $input_dir = $data_info->input_dir;
	my $javavm_list_yaml = file($input_dir, 'java_vm_list.yaml')->slurp;
	my $stat_yaml = YAML::Tiny->read_string($javavm_list_yaml);
	my %jvms = ();
	for my $java_info(@{$stat_yaml->[0]}) {
		my $pid  = $java_info->{pid};
	    if (my $info = alias_instance($java_info)) {
		    $jvms{$pid} = $info;
	    }
	}
	return \%jvms;
}

# Date       Time     VMID  EU        OU        PU        YGC    FGC    YGCT      FGCT      THREAD
# 2015/07/20 18:34:18 23972  16717688     32768   4743720      4      0     24053         0      4
# 2015/07/20 18:34:18 3796   38117464  57706352  24301064     43      0    783207         0     19
# 2015/07/20 18:34:18 3745   51740896  53195592  21763680     30      0    543732         0     10

sub parse {
    my ($self, $data_info) = @_;

	my %results;
	my $step = 60;
	my @headers = qw/eu ou pu ygc:COUNTER fgc:COUNTER ygct:COUNTER fgct:COUNTER thread/;

	my $jvms = $self->read_java_vm_list($data_info);
	$data_info->step($step);
	my $host = $data_info->host;
	my $sec  = $data_info->start_time_sec->epoch;
	if (!$sec) {
		return;
	}
	open( IN, $data_info->input_file ) || die "@!";
	while (my $line = <IN>) {
		$line=~s/(\r|\n)*//g;			# trim return code
		next if ($line=~/^Date/);		# skip header
		my ($dt, $tm, $pid, $body) = split(' ', $line, 4);
		$dt=~s/\//-/g;
		$results{$pid}{$sec} = $body;
		$sec += $step;
	}
	close(IN);

	for my $pid(keys %results) {
		if (defined(my $instance = $jvms->{$pid})) {
			my $device = $instance->{device};
			my $text = $instance->{device_text};
			next if ($device eq 'Etc');
			$data_info->regist_device($host, 'Jvmstat', 'jstat', $device, $text, \@headers);
			$data_info->simple_report("device/jstat__${device}.txt", $results{$pid}, \@headers);
		}
	}
	return 1;
}

1;
