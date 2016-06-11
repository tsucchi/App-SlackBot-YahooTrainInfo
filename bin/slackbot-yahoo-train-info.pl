#!/usr/bin/perl
use v5.20;
use App::SlackBot::YahooTrainInfo;
use Config::Pit;

my $config = pit_get('slackbot_yahoo_train_info');

my $app = App::SlackBot::YahooTrainInfo->new( token => $config->{token} );
$app->run();
