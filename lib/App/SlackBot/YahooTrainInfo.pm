package App::SlackBot::YahooTrainInfo;
use v5.20;
use Moo;

our $VERSION = "0.01";

use utf8;
binmode STDOUT, ':utf8';

use Furl;
use HTTP::Request::Common;
use Selenium::Remote::Driver;
use Selenium::PhantomJS;
use JSON::XS;
use File::Slurp;
use Encode;
use AnyEvent;

has token => (
    is => 'ro',
    required => 1,
);

has train_info_url => (
    is => 'ro',
    required => 1,
    default => 'http://transit.yahoo.co.jp/traininfo/area/4/',
);

has train_info_trouble_line_element_css => (
    is => 'ro',
    required => 1,
    default => 'div#mdStatusTroubleLine table tbody tr',
);

has driver => (
    is => 'ro',
    required => 1,
    lazy => 1,
    builder => sub {
        return Selenium::PhantomJS->new();
    },
);

has slack_user => (
    is => 'ro',
    required => 1,
    default => 'train-info-bot',
);

has slack_icon_emoji => (
    is => 'ro',
    required => 1,
    default => ':trains:',
);

has slack_channel => (
    is => 'ro',
    required => 1,
    default => '#general',
);

# 前にアクセスした時の情報(ファイル名)。同じ情報だったらポストする意味がないため
has previous_filename => (
    is => 'ro',
    required => 1,
    default => 'previous.txt',
);

has timer_interval => (
    is => 'ro',
    required => 1,
    default => 10 * 60, #10min
);

sub run {
    my ($self) = @_;
    my $cv = AnyEvent->condvar;
    my $timer = AnyEvent->timer(
        interval => $self->timer_interval,
        cb       => sub { $self->_run_once() },
    );
    local $SIG{INT} = sub {
        $cv->send;
    };
    $cv->recv;
}

sub _run_once {
    my ($self) = @_;
    my $message = $self->_scrape_train_info();
    my $previous_message = $self->_read_previous_message();

    if ( $message && $message ne $previous_message ) {
        $self->_post_to_slack($message);
        write_file($self->previous_filename, encode_utf8($message));
    }
    elsif ( !$message && $previous_message ) { #前はなんかあったけど、今は何事もない
        $self->_post_to_slack('復旧したかも');
        write_file($self->previous_filename, encode_utf8($message));
    }
    else {
        say "skipping... no trouble or same message : $message";
    }
}

sub _read_previous_message {
    my ($self) = @_;
    if ( !-e $self->previous_filename ) {
        return '';
    }
    my $message = read_file $self->previous_filename;
    return decode_utf8($message);
}

sub _scrape_train_info {
    my ($self) = @_;
    my $driver = $self->driver;
    $driver->get($self->train_info_url);
    my @elements = $driver->find_elements($self->train_info_trouble_line_element_css, 'css');

    shift @elements; #ヘッダを捨てる
    my @mes = map { $_->get_text } @elements;
    if ( @mes ) {
        unshift @mes, $self->train_info_url;
    }
    my $message = join("\n", @mes);
    return $message;
}

sub _post_to_slack {
    my ($self, $message) = @_;
    my $req = POST 'https://slack.com/api/chat.postMessage',
        Content => [
            token      => $self->token,
            channel    => $self->slack_channel,
            text       => $message,
            username   => $self->slack_user,
            icon_emoji => $self->slack_icon_emoji,
        ];
    my $res = Furl->new->request($req);

    if ( !$res->is_success ) {
        die $res->status . ":" .$res->message
    }
}

sub DESTROY {
    my ($self) = @_;
    if ( defined $self->driver ) {
        $self->driver->quit();
    }
}


1;
__END__

=encoding utf-8

=head1 NAME

App::SlackBot::YahooTrainInfo - It's new $module

=head1 SYNOPSIS

    use App::SlackBot::YahooTrainInfo;

=head1 DESCRIPTION

App::SlackBot::YahooTrainInfo is ...

=head1 LICENSE

Copyright (C) Takuya Tsuchida.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Takuya Tsuchida E<lt>takuya.tsuchida@gmail.comE<gt>

=cut

