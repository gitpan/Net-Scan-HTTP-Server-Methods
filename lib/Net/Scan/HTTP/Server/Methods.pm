package Net::Scan::HTTP::Server::Methods;

use 5.008006;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use Carp;
use IO::Socket;

our $VERSION = '0.01';
$VERSION = eval $VERSION;

__PACKAGE__->mk_accessors( qw(host port timeout http_version user_agent debug));

$| = 1;

sub scan {

	my $self         = shift;
	my $host         = $self->host;
	my $port         = $self->port         || 80;
	my $timeout      = $self->timeout      || 8;
	my $http_version = $self->http_version || '1.1';
	my $user_agent   = $self->user_agent   || 'Mozilla/5.0';
	my $debug        = $self->debug        || 0;

	my $method       = "OPTIONS";
	my $maxlen       = 1024;
	my $CRLF         = "\015\012";

	my $connect = IO::Socket::INET->new(
		PeerAddr => $host,
		PeerPort => $port,
		Proto    => 'tcp',
		Timeout  => $timeout
	);
	
	my $options;

	if ($connect){

		print $connect "$method / HTTP/$http_version$CRLF";
		print $connect "User-Agent: $user_agent$CRLF";
		print $connect "Host: $host$CRLF";
		print $connect "$CRLF";

		$SIG{ALRM} = \&timed_out;
		eval{
			alarm($timeout);

			$connect->recv($options,$maxlen);
	
			close $connect; 
			alarm(0);
		};

		my @results = split(/\n/,$options);

		my $check = 0;

		if (@results){
			my @options = grep(/^Allow:/, @results);
			foreach my $line (@results){
				if ($line =~ /^Allow:/){
					(undef,$options) = split(/:/,$line);
					$options =~ s/^\s+//;
					$check = 1;
				}
			}
			
			if ($check == 1){
				return "$options";
			} else{
				return "unknown";
			}
		}
	} else {
		if ($debug){
			return "connection refused";
		}
	}
}

sub timed_out{
	die "timeout while connecting to server";
}

1;
__END__

=head1 NAME

Net::Scan::HTTP::Server::Methods - retrieve allowed http methods 

=head1 SYNOPSIS

  use Net::Scan::HTTP::Server::Methods;

  my $host = $ARGV[0];

  my $scan = Net::Scan::HTTP::Server::Methods->new({
    host    => $host,
    timeout => 5
  });

  my $results = $scan->scan;

  print "$host $results\n" if $results;

=head1 DESCRIPTION

A simple module for retrieve allowed http methods.

=head1 METHODS

=head2 new

The constructor. Given a host returns a L<Net::Scan::HTTP::Server::Methods> object:

  my $scan = Net::Scan::HTTP::Server::Methods->new({
    host         => '127.0.0.1',
    port         => 80,
    timeout      => 5,
    http_version => '1.1', 
    user_agent   => 'Mozilla/5.0', 
    debug        => 0 
  });

Optionally, you can also specify :

=over 2

=item B<port>

Remote port. Default is 80;

=item B<timeout>

Default is 8 seconds;

=item B<http_version>

Set the HTTP protocol version. Default is '1.1'.

=item B<user_agent>

Set the product token that is used to identify the user agent on the network. The agent value is sent as the "User-Agent" header in the requests. Default is 'Mozilla/5.0'.

=item B<debug>

Set to 1 enable debug. Debug displays "connection refused" when an HTTP server is unrecheable. Default is 0;

=back

=head2 scan 

Scan the target.

  $scan->scan;

=head1 SEE ALSO

L<LWP>

L<WWW::Mechanize>

LW2 L<http://www.wiretrip.net/rfp/lw.asp>

RFC 2616

=head1 AUTHOR

Matteo Cantoni, E<lt>mcantoni@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

You may distribute this module under the terms of the Artistic license.
See Copying file in the source distribution archive.

Copyright (c) 2006, Matteo Cantoni

=cut
