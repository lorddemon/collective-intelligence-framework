package CIF::FeedParser::Plugin::Pull::Http;

require LWP::Simple;
require LWP::UserAgent;

sub pull {
    my $class = shift;
    my $f = shift;
    return unless($f->{'feed'} =~ /^http/);
    return if($f->{'cif'});

    my $content;
    if($f->{'feed_user'}){
       my $ua = LWP::UserAgent->new();
       my $req = HTTP::Request->new(GET => $f->{'feed'});
       $req->authorization_basic($f->{'feed_user'},$f->{'feed_password'});
       my $ress = $ua->request($req);
       die('request failed: '.$ress->status_line()."\n") unless($ress->is_success());
       $content = $ress->decoded_content();
    } else {
        $content = LWP::Simple::get($f->{'feed'}) || die('failed to get feed: '.$f->{'feed'}.': '.$!);
    }
    return($content);
}

1;
