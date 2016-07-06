package Plack::Middleware::Curlizer;
use strict;
use warnings;

use Plack::Request;
use parent 'Plack::Middleware';
use Plack::Util::Accessor qw/
    callback
/;

our $VERSION = '0.01';

sub call {
    my($self, $env) = @_;

    my $req = Plack::Request->new($env);

    my $curl = $self->_build_curl_cmd($req);

    if ($self->callback && ref($self->callback) eq 'CODE') {
        $self->callback->($curl, $req, $env);
    }

    my $res = $self->app->($env);
}

sub _build_curl_cmd {
    my ($self, $req) = @_;

    my @cmd = ('curl', sprintf(qq|'%s'|, $req->request_uri));

    unless ($req->method eq 'GET') {
        push @cmd, '-X', $req->method;
    }

    my $http_header_str = $req->headers->as_string;
    my @headers = split "\n", $http_header_str;

    for my $h (@headers) {
        my ($k, $v) = split /:\s+/, $h;
        push @cmd, '-H', qq|'$k: $v'|;
    }

    if ($req->method eq 'POST') {
        push @cmd, '--data', sprintf(qq|'%s'|, $req->content);
    }

    return join(" ", @cmd);
}

1;

__END__

=encoding UTF-8

=head1 NAME

Plack::Middleware::Curlizer - Building Curl Command from Plack Request


=head1 SYNOPSIS

    enable 'Curlizer',
        callback => sub {
            my ($curl, $req, $env) = @_;
            print "$curl\n";
        };


=head1 DESCRIPTION

Plack::Middleware::Curlizer gives you a command line for an HTTP request by B<Curl> from Plack Request.

This module has been inspired by the "copy as cURL" feature on Web Browsers.


=head1 METHODS

=head2 call


=head1 REPOSITORY

=begin html

<a href="http://travis-ci.org/bayashi/Plack-Middleware-Curlizer"><img src="https://secure.travis-ci.org/bayashi/Plack-Middleware-Curlizer.png"/></a> <a href="https://coveralls.io/r/bayashi/Plack-Middleware-Curlizer"><img src="https://coveralls.io/repos/bayashi/Plack-Middleware-Curlizer/badge.png?branch=master"/></a>

=end html

Plack::Middleware::Curlizer is hosted on github: L<http://github.com/bayashi/Plack-Middleware-Curlizer>

I appreciate any feedback :D


=head1 AUTHOR

Dai Okabayashi E<lt>bayashi@cpan.orgE<gt>


=head1 SEE ALSO

C<curl> <https://curl.haxx.se/>

L<Plack::Middleware>


=head1 LICENSE

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=cut
