#!/usr/bin/env perl
use utf8;
use warnings;

use FindBin;
use Plack::Builder;
use lib "$FindBin::Bin/lib/";
use FakeAuthRequest;

builder {
    enable '+FakeAuthRequest',
        cookie => '_oauth2_proxy',
        redirect_on_401 => '/secret/oauth2/start?rd=/secret/',
        auth_request => 'http://127.0.0.1:4180/secret/oauth2/auth';
    mount '/' => sub {
        return [ 200, [], ['OK'] ];
    }
}

