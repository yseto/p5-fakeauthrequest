package FakeAuthRequest;
use strict;
use parent qw(Plack::Middleware);

use Plack::Util::Accessor qw( cookie redirect_on_401 auth_request );
use Plack::Request;
use Furl;

sub prepare_app {
    my $self = shift;
    die 'need cookie' unless $self->cookie;
    die 'need redirect_on_401' unless $self->redirect_on_401;
    die 'need auth_request' unless $self->auth_request;
}

sub call {
    my ( $self, $env ) = @_;
    my $req = Plack::Request->new($env);
    return $self->redirect
        unless defined $req->cookies->{$self->cookie};

    # XXX
    my $key = $self->cookie;
    my $auth_res = Furl->new(
        headers => [Cookie => "$key=" . $req->cookies->{$key}]
    )->get($self->auth_request);

    return $self->redirect
        unless $auth_res->is_success;
    $self->app->($env);

#   use Cookie::Baker;
#   my $res = $self->app->($env);
#   $self->response_cb($res, sub {
#       my $cookie = bake_cookie($key, {value => $req->cookies->{$key}});
#       Plack::Util::header_push($res->[1], 'Set-Cookie', $cookie);
#   });

}

sub redirect {
    my $self = shift;
    [ 302, [Location => $self->redirect_on_401], [] ];
}

1;

