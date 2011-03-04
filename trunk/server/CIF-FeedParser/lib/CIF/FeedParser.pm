package CIF::FeedParser;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use DateTime::Format::DateParse;
use DateTime;
use Regexp::Common qw/net/;
use Regexp::Common::net::CIDR;
use Encode qw/decode_utf8 encode_utf8/;
use Data::Dumper;
use File::Type;
use threads;
use threads::shared;
use Linux::Cpuinfo;

# Preloaded methods go here.

sub new {
    my ($class,%args) = (shift,@_);
    my $self = {};
    bless($self,$class);
    return $self;
}

sub get_feed { 
    my $f = shift;
    my $content = threads->create('_get_feed',$f)->join();
    # auto-decode the content if need be
    $content = _decode($content);

    # encode to utf8
    $content = encode_utf8($content);
    # remove any CR's
    $content =~ s/\r//g;
    return($content);
}

sub _get_feed {
    my $f = shift;
    my $content;
    for($f->{'feed'}){
        if(/^(\/\S+)/){
            open(F,$1) || die($!.': '.$_);
            my @lines = <F>;
            close(F);
            $content = join('',@lines);
        } elsif($f->{'feed_user'}) {
            require LWP::UserAgent;
            my $ua = LWP::UserAgent->new();
            my $req = HTTP::Request->new(GET => $f->{'feed'});
            $req->authorization_basic($f->{'feed_user'},$f->{'feed_password'});
            my $ress = $ua->request($req);
            die('request failed: '.$ress->status_line()."\n") unless($ress->is_success());
            $content = $ress->decoded_content();
        } else {
            require LWP::Simple;
            $content = LWP::Simple::get($f->{'feed'}) || die('failed to get feed: '.$f->{'feed'}.': '.$!);
        }
    }
    return $content;
}


sub parse {
    my $f = shift;
    my $content = get_feed($f);

    # see if we designate a delimiter
    if(my $d = $f->{'delimiter'}){
        require CIF::FeedParser::ParseDelim;
        return CIF::FeedParser::ParseDelim::parse($f,$content,$d);
    } else {
        # try to auto-detect the file
        if($content =~ /<\?xml version=/){
            if($content =~ /<rss version=/){
                require CIF::FeedParser::ParseRss;
                return CIF::FeedParser::ParseRss::parse($f,$content);
            } else {
                require CIF::FeedParser::ParseXml;
                return CIF::FeedParser::ParseXml::parse($f,$content);
            }
        } elsif($content =~ /^{?\[/){
            # possible json content
            require CIF::FeedParser::ParseJson;
            return CIF::FeedParser::ParseJson::parse($f,$content);
        ## TODO -- fix this; double check it
        } elsif($content =~ /^#?\s?"\S+","\S+"/){
            require CIF::FeedParser::ParseCsv;
            return CIF::FeedParser::ParseCsv::parse($f,$content);
        } else {
            require CIF::FeedParser::ParseTxt;
            return CIF::FeedParser::ParseTxt::parse($f,$content);
        }
    }
}

sub _decode {
    my $data = shift;

    my $ft = File::Type->new();
    my $t = $ft->mime_type($data);
    for($t){
        if(/gzip/){
            require CIF::FeedParser::DecodeGzip;
            return CIF::FeedParser::DecodeGzip::decode($data);
        }
        return $data;
    }
}

sub normalize_date {
    my $dt = shift;
    return $dt if($dt =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/);
    if($dt && ref($dt) ne 'DateTime'){
        if($dt =~ /^\d+$/){
            if($dt =~ /^\d{8}$/){
                $dt.= 'T00:00:00Z';
                $dt = eval { DateTime::Format::DateParse->parse_datetime($dt) };
                unless($dt){
                    $dt = DateTime->from_epoch(epoch => time());
                }
            } else {
                $dt = DateTime->from_epoch(epoch => $dt);
            }
        } elsif($dt =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(\S+)?$/) {
            my ($year,$month,$day,$hour,$min,$sec,$tz) = ($1,$2,$3,$4,$5,$6,$7);
            $dt = DateTime::Format::DateParse->parse_datetime($year.'-'.$month.'-'.$day.' '.$hour.':'.$min.':'.$sec,$tz);
        } else {
            $dt =~ s/_/ /g;
            $dt = DateTime::Format::DateParse->parse_datetime($dt);
            return undef unless($dt);
        }
    }
    $dt = $dt->ymd().'T'.$dt->hms().'Z';
    return $dt;
}

sub _sort_detecttime {
    my @recs = @_;

    foreach (@recs){
        delete($_->{'regex'}) if($_->{'regex'});
        my $dt = $_->{'detecttime'};
        if($dt){
            $dt = normalize_date($dt);
        }
        unless($dt){
            $dt = DateTime->from_epoch(epoch => time());
            if(lc($_->{'detection'}) eq 'hourly'){
                $dt = $dt->ymd().'T'.$dt->hour.':00:00Z';
            } elsif(lc($_->{'detection'}) eq 'monthly') {
                $dt = $dt->year().'-'.$dt->month().'-01T00:00:00Z';
            } else {
                $dt = $dt->ymd().'T00:00:00Z';
            }
        }
        $_->{'detecttime'} = $dt;
        $_->{'description'} = '' unless($_->{'description'});
    }
    @recs = sort { $b->{'detecttime'} cmp $a->{'detecttime'} } @recs;
    return(@recs);
}

sub _insert {
    my $f = shift;
    my $b = shift;
    my $a = $f->{'hash_md5'} || $f->{'address'};
    return unless($a && length($a) > 2);
    $a = encode_utf8($a);
    $f->{'impact'} = lc($f->{'impact'});
    unless($f->{'description'}){
        $f->{'description'} = $f->{'impact'};
    }
    $f->{'description'} = lc($f->{'description'});

    my $bucket = $b;
    if(!$bucket){
        for($a){
            $bucket = 'CIF::Message::';
            if(/^([A-Za-z0-9.-]+\.[a-zA-Z]{2,6})$/ && ($f->{'impact'} !~ / url/)){
                $bucket .= 'DomainSimple';
                last;
            }
            if(/^$RE{'net'}{'IPv4'}$/ || /^$RE{'net'}{'CIDR'}{'IPv4'}$/){
                $bucket .= 'InfrastructureSimple';
                last;
            }
            if(/^[a-fA-F0-9]{32,40}$/){
                $bucket .= 'Malware';
                last;
            }
            if(/[\w]+@[\w]+/){
                $bucket .= 'Email';
                last;
            } else {
                $bucket .= 'UrlSimple';
                # catch urls that have no leading http, makes other regex easier
                if($a =~ /^[A-Za-z0-9.-]+\.[a-zA-Z]{2,6}/){
                    $a = 'http://'.$a;
                    $f->{'address'} = 'http://'.$f->{'address'};
                }
            }
        }
    }
    eval "require $bucket";
    die($@) if($@);
    my $id = $bucket->insert({ %{$f} });
    my $rid;
    if($id =~ /^\d+$/){
        $rid = $id->impact().' -- '.$id->description().' -- '.$id->detecttime().' -- '.$id->uuid();
    } else {
        $rid = $id;
    }
    print $f->{'source'}.' -- '.$a.' -- '.$rid."\n";
    return(0);
}

sub insert {
    my ($full,@recs) = (shift,@_);
    my $goback = DateTime->from_epoch(epoch => (time() - (84600 * 5)));
    $goback = $goback->ymd().'T'.$goback->hms().'Z';
    @recs = _sort_detecttime(@recs);

    foreach (@recs){
        foreach my $key (keys %$_){
            next unless($_->{$key});
            if($_->{$key} =~ /<(\S+)>/){
                my $x = $_->{$1};
                if($x){
                    $_->{$key} =~ s/<\S+>/$x/;
                }
            }
        }
    }
    foreach(@recs){
        unless($full){
            next if(($_->{'detecttime'} cmp $goback) == -1);
        }
        _insert($_);
    }
    return(0);
}

sub throttle {
    my $throttle = shift;
    my $cpu = Linux::Cpuinfo->new();
    return(1) unless($cpu);
    my $cores = $cpu->num_cpus();
    return(1) unless($cores && $cores =~ /^\d$/);
    return(1) if($cores eq 1);
    return($cores) unless($throttle && $throttle ne 'medium');
    return($cores/2) if($throttle eq 'low');
    return($cores * 2);
}

sub _split_batches {
    my @recs = @_;
    my $tc = $recs[0]->{'threads_count'};
    my @batches;
    my $batch = (($#recs/$tc) == int($#recs/$tc)) ? ($#recs/$tc) : (int($#recs/$tc) + 1);
    for(my $x = 0; $x <= $#recs; $x += $batch){
        my $start = $x;
        my $end = ($x+$batch);
        $end = $#recs if($end > $#recs);
        my @a = @recs[$x ... $end];
        push(@batches,\@a);
        $x++;
    }
    return(@batches);
}

sub t_insert {
    my ($full,$fctn,@recs) = (shift,shift,@_);
    $fctn = 'CIF::FeedParser::insert' unless($fctn);
    my @batches = _split_batches(@recs);
    # don't thread me out if we only have one batch
    # Crypt::SSLeay is NOT really thread safe, so we do simple https feeds with 1 bath where possible
    return insert($full,@recs) unless($#batches > -1);
    # go nuts...
    foreach(@batches){
        my $t = threads->create($fctn,$full,@{$_});
    }
    while(threads->list()){
        my @joinable = threads->list(threads::joinable);
        unless($#joinable > -1){
            sleep(2);
            next();
        }
        foreach(@joinable){
            # crypto libs might seg fault here. its OK
            ## TODO -- patch here for Crypt::SSLeay
            ## https://rt.cpan.org/Ticket/Display.html?id=41007
            $_->join();
        }
    }
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::FeedParser - Perl extension for parsing different types of feeds and inserting into CIF

=head1 SYNOPSIS

  use CIF::FeedParser;
  my $c = Config::Simple->new($config);
  my @items = CIF::FeedParser::parse($c)
  my $full_load = 1;
  CIF::FeedParser::t_insert($full_load,undef,@items);


  my $content = CIF::FeedParser::get_feed($c);
  my @lines = split("\n",$content);
  my @items;
  foreach(@lines){
    # .. do something
    my $h = {
      address => 'example.com',
      portlist => 123,
      %$c,
    };
    push(@items,$h);
  }
  
  CIF::FeedParser::t_insert($full_load,undef,@items);

=head1 SEE ALSO

script/cif_feed_parser for more doc and usage tips

http://code.google.com/p/collective-intelligence-framework

=head1 AUTHOR

Wes Young, E<lt>wes@barely3am.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by REN-ISAC and The Trustees of Indiana University

Copyright (C) 2011 by Wes Young

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
