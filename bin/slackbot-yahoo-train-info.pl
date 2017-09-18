#!/usr/bin/perl
use v5.20;
use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::Bin, '..', 'lib');
use App::SlackBot::YahooTrainInfo;

my $token = $ENV{SLACKBOT_YAHOO_TRAIN_INFO_SLACK_TOKEN};

if ( !defined $token ) {
    die "SLACKBOT_YAHOO_TRAIN_INFO_SLACK_TOKEN is not set";
}

my $app = App::SlackBot::YahooTrainInfo->new( token => $token );
$app->run();
