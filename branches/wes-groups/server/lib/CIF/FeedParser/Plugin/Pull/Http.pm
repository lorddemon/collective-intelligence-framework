package CIF::FeedParser::Plugin::Pull::Http;

require LWP::Simple;
require LWP::UserAgent;

## TODO -- remove LWP::Simple
sub pull {
    my $class = shift;
    my $f = shift;
    return unless($f->{'feed'} =~ /^http/);
    return if($f->{'cif'});

    my $timeout = $f->{'timeout'} || 10;

    my $content;
    if($f->{'feed_user'}){
       my $ua = LWP::UserAgent->new();
       $ua->timeout($timeout);
       my $req = HTTP::Request->new(GET => $f->{'feed'});
       $req->authorization_basic($f->{'feed_user'},$f->{'feed_password'});
       my $ress = $ua->request($req);
       unless($ress->is_success()){
            print('request failed: '.$ress->status_line()."\n");
            return;
       }
       $content = $ress->decoded_content();
    } else {
        $content = LWP::Simple::get($f->{'feed'});
        print 'failed to get feed: '.$f->{'feed'}."\n" unless($content);
    }
    return($content);
}

1;
