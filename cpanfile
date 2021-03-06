requires 'perl', '5.008001';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

requires 'AnyEvent';
requires 'Encode';
requires 'File::Slurp';
requires 'Furl';
requires 'HTTP::Request::Common';
requires 'JSON::XS';
requires 'Moo';
requires 'Web::Query';
requires 'IO::Socket::SSL';
requires 'perl', 'v5.20.0';

on configure => sub {
    requires 'Module::Build::Tiny', '0.035';
};

on test => sub {
    requires 'Test::More', '0.98';
};
