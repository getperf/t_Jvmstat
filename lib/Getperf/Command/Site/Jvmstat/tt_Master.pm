package Getperf::Command::Master::Jvmstat;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw/alias_instance/;

our $db = {
	_node_dir => undef,
	instances => undef,
};

sub new {bless{},+shift}

sub alias_instance {
	my ($java_info) = @_;

	my $pid     = $java_info->{pid};
    my $command = $java_info->{'sun.rt.javaCommand'};
    my $args    = $java_info->{'java.rt.vmArgs'};

    my ($device, $device_text);

    # Tomcat Servlet engine -Dcatalina.base=/usr/local/tomcat-data
    if ($command=~m|^org.apache.catalina.|) {
    	if ($args=~m|-Dcatalina.base=(.*?)\s|) {
    		my $catalina_base = $1;
    		$device_text = "Apache Tomcat - ${catalina_base}";
    		$catalina_base =~ s/(?:_|\/|-)(.)/\U$1/g;
    		$device = "tomcat.${catalina_base}";
    	}
    }

	return ($device) ? {device => $device, device_text => $device_text} : undef;
}

1;
