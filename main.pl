#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use IO::File;
use JSON;
use Data::Dumper;

#IN: reciever_name OUT: slack_channel_url
sub get_slack_url{
	my $reciever = $_[0];
	open(FH, "./Conf/url_list.txt")or die "Can\'t open file stream (./Conf/url_list.txt)";
	while(<FH>){
		my $line = $_;
		my @line_split = split(/ /,$line);
		my ($reciever_name, $slack_channel_url) = @line_split;
		if (index($reciever_name, $reciever) != -1) {
			return $slack_channel_url;
		}
	}
	close;
}

#IN: from,to,content OUT: message_text,message_length
sub get_slack_message_default{
	my ($sender, $content) = @_;
	my ($message_text, $message_length);
	
	$message_length = 240 + length($sender) + length($content);
	$message_text = "{\x09\x22blocks\x22: [\x09\x09{\x09\x09\x09\x22type\x22: \x22section\x22,\x09\x09\x09\x22text\x22: {\x09\x09\x09\x09\x22type\x22: \x22mrkdwn\x22,\x09\x09\x09\x09\x22text\x22: \x22Nouveau message de $sender\x22\x09\x09\x09}\x09\x09},\x09\x09{\x09\x09\x09\x22type\x22: \x22context\x22,\x09\x09\x09\x22elements\x22: [\x09\x09\x09\x09{\x09\x09\x09\x09\x09\x22type\x22: \x22plain_text\x22,\x09\x09\x09\x09\x09\x22text\x22: \x22Contenu: $content\x22,\x09\x09\x09\x09\x09\x22emoji\x22: true\x09\x09\x09\x09}\x09\x09\x09]\x09\x09}\x09]}";
	
	my @return_tab = ($message_length, $message_text);
	return @return_tab;
}

#IN: datime,device_name,content OUT: message_text,message_length
sub get_slack_message_details{
	my ($datime, $device, $content) = @_;
	my ($message_text, $message_length);
	
	$message_length = 553 + length($datime) + length($device) + length($content);
	$message_text = "{\x09\x22blocks\x22: [\x09\x09{\x09\x09\x09\x22type\x22: \x22header\x22,\x09\x09\x09\x22text\x22: {\x09\x09\x09\x09\x22type\x22: \x22plain_text\x22,\x09\x09\x09\x09\x22text\x22: \x22Nouveau message\x22,\x09\x09\x09\x09\x22emoji\x22: true\x09\x09\x09}\x09\x09},\x09\x09{\x09\x09\x09\x22type\x22: \x22divider\x22\x09\x09},\x09\x09{\x09\x09\x09\x22type\x22: \x22section\x22,\x09\x09\x09\x22text\x22: {\x09\x09\x09\x09\x22type\x22: \x22mrkdwn\x22,\x09\x09\x09\x09\x22text\x22: \x22*Alerte deconnexion*\x22\x09\x09\x09}\x09\x09},\x09\x09{\x09\x09\x09\x22type\x22: \x22section\x22,\x09\x09\x09\x22text\x22: {\x09\x09\x09\x09\x22type\x22: \x22mrkdwn\x22,\x09\x09\x09\x09\x22text\x22: \x22Un problème a était détecté le $datime sur $device.\x5cn_ $content _\x22\x09\x09\x09}\x09\x09},\x09\x09{\x09\x09\x09\x22type\x22: \x22divider\x22\x09\x09},\x09\x09{\x09\x09\x09\x22type\x22: \x22context\x22,\x09\x09\x09\x22elements\x22: [\x09\x09\x09\x09{\x09\x09\x09\x09\x09\x22type\x22: \x22plain_text\x22,\x09\x09\x09\x09\x09\x22text\x22: \x22citypassenger | support client\x22,\x09\x09\x09\x09\x09\x22emoji\x22: true\x09\x09\x09\x09}\x09\x09\x09]\x09\x09}\x09]}";
	
	my @return_tab = ($message_length, $message_text);
	return @return_tab;
}

#IN: target, content_length, content OUT: 1
sub post_http{
	my ($reciever, $content_length, $content) = @_;
	my $url = get_slack_url($reciever);
	my $ua = LWP::UserAgent->new( 'send_te' => '0' );
	my $r  = HTTP::Request->new(
		'POST' =>
	"$url",
		[
		    'Accept'         => '*/*',
		    'User-Agent'     => 'curl/7.55.1',
		    'Content-Length' => "$content_length",
		    'Content-Type'   => 'application/json'
		],
	"$content"
	);
	my $res = $ua->request( $r, );
	return 1;
}

#IN: 3 or 5 args depends what type of message you want OUT: status_http_post or error due to args number
sub send_slack_message{
	my $nb_args = @_;
	if($nb_args == 3){
		my ($sender, $reciever, $content) = @_;
		my ($message_length, $message_text) = get_slack_message_default($sender, $content);
		my $status = post_http($reciever, $message_length, $message_text);
		return $status;
	} elsif($nb_args == 5){
		my ($sender, $reciever, $content, $datime, $device) = @_;
		my ($message_length, $message_text) = get_slack_message_details($datime, $device, $content);
		my $status = post_http($reciever, $message_length, $message_text);
		return $status;
	} else {
		die "send_slack_message() require 3 or 5 arguments\n";
	}
}

#in: text_format_json out: hash table
sub i_json {
	my $text = decode_json($_[0]);
	print  Dumper($text);
}

#in: from,to,datime,title,body out: text_format_json
sub o_json {
	my ($to ,$datime ,$title ,$body) = @_;
	my %rec_hash = ('reciever' => $to, 'datime' => $datime, 'title' => $title, 'body' => $body);
	my $json = encode_json \%rec_hash;
	return $json;
}

#no IN/OUT , just display the sended messages historic
sub display_sended_messages{
	open(FH, "./Data/sended.json")or die "Can\'t open file stream (./Data/sended.json)";
	printf "\n";
	while(<FH>){
		i_json($_);
		printf "\n";
	}
	close;
}

#IN: reciever_name,date_time_alert,title_alert,content_alert OUT: nothing
sub update_sended_messages{
	my ($reciever ,$datime ,$title ,$content) = @_;
	my $json = o_json($reciever ,$datime ,$title ,$content);
	my $fh = IO::File->new("./Data/sended.json", O_WRONLY|O_APPEND);
	if (defined $fh) {
		print $fh "$json\n";
		my $pos = $fh->getpos;
		$fh->setpos($pos);
		undef $fh;
	}
	autoflush STDOUT 1;
}

sub main{
	
}

main();

