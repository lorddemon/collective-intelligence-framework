package CIF::FeedParser;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use DateTime::Format::DateParse;
use DateTime;
use Regexp::Common qw/net URI/;
use Regexp::Common::net::CIDR;
use Encode qw/decode_utf8 encode_utf8/;
use Data::Dumper;
use File::Type;
use threads;
use threads::shared;
use Linux::Cpuinfo;
use Module::Pluggable require => 1;
use Digest::MD5 qw/md5_hex/;
use Digest::SHA1 qw/sha1_hex/;
use URI::Escape;
# Preloaded methods go here.

sub new {
    my ($class,%args) = (shift,@_);
    my $self = {};
    bless($self,$class);
    return $self;
}

sub get_feed { 
    my $f = shift;
    my ($content,$err) = threads->create('_get_feed',$f)->join();
    return(undef,$err) if($err);
    return(undef,'no content') unless($content);
    # auto-decode the content if need be
    $content = _decode($content);

    # encode to utf8
    $content = encode_utf8($content);
    #$content =~ s/[^[:print:]]//g;
    # remove any CR's
    $content =~ s/\r//g;
    uri_escape($content);
    delete($f->{'feed'});
    return($content);
}

sub _get_feed {
    my $f = shift;
    return unless($f->{'feed'});
    my @pulls = __PACKAGE__->plugins();
    @pulls = grep(/::Pull::/,@pulls);
    foreach(@pulls){
        if(my $content = $_->pull($f)){
            return(undef,$content);
        }
    }
    return('could not pull feed',undef);
}


## TODO -- turn this into plugins
sub parse {
    my $f = shift;
    my ($content,$err) = get_feed($f);
    return($err,undef) if($err);

    my @array;
    # see if we designate a delimiter
    if(my $d = $f->{'delimiter'}){
        require CIF::FeedParser::ParseDelim;
        @array = CIF::FeedParser::ParseDelim::parse($f,$content,$d);
    } else {
        # try to auto-detect the file
        if($content =~ /<\?xml version=/){
            if($content =~ /<rss version=/){
                require CIF::FeedParser::ParseRss;
                @array = CIF::FeedParser::ParseRss::parse($f,$content);
            } else {
                require CIF::FeedParser::ParseXml;
                @array = CIF::FeedParser::ParseXml::parse($f,$content);
            }
        } elsif($content =~ /^?\[{/){
            # possible json content or CIF
            if($content =~ /^{"status"\:/){
                require CIF::FeedParser::ParseCIF;
                @array = CIF::FeedParser::ParseCIF::parse($f,$content);
            } else {
                require CIF::FeedParser::ParseJson;
                @array = CIF::FeedParser::ParseJson::parse($f,$content);
            }
        ## TODO -- fix this; double check it
        } elsif($content =~ /^#?\s?"\S+","\S+"/){
            require CIF::FeedParser::ParseCsv;
            @array = CIF::FeedParser::ParseCsv::parse($f,$content);
        } else {
            require CIF::FeedParser::ParseTxt;
            @array = CIF::FeedParser::ParseTxt::parse($f,$content);
        }
    }
    return(undef,@array);
}

sub _decode {
    my $data = shift;

    my $ft = File::Type->new();
    my $t = $ft->mime_type($data);
    my @plugs = __PACKAGE__->plugins();
    @plugs = grep(/Decode/,@plugs);
    foreach(@plugs){
        if(my $ret = $_->decode($data,$t)){
            return($ret);
        }
    }
}

## TODO -- commit some of this to DateTime::Format::DateParse
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
    my $a = $f->{'malware_md5'} || $f->{'address'};
    return unless($a && length($a) > 2);
    $a = encode_utf8($a);
    $f->{'impact'} = lc($f->{'impact'});
    unless($f->{'description'}){
        $f->{'description'} = $f->{'impact'};
    }
    $f->{'description'} = lc($f->{'description'});

    require CIF::Archive;
    my $bucket = CIF::Archive->new();
    if($f->{'database'}){
        local $^W = 0;
        $bucket->connection($f->{'database'});
        local $^W = 1;
    }
    # some feeds don't put the http(s) in front
    # Regexp::Common::URI doesn't do a good job of recognizing the format of a URL
    ## TODO -- submit a fix to Regexp::Common::URI
    if($f->{'address'} && $f->{'impact'} && $f->{'impact'} =~ /url$/ && $f->{'address'} !~ /^(http|https|ftp):\/\//){
        if($f->{'address'} =~ /[\/]+/){
            $f->{'address'} = 'http://'.$f->{'address'};
        }
    }
    if($f->{'address'} && $f->{'address'} =~ /^$RE{'URI'}/){
        # we do this here so ::Plugin::Hash will pick it up
        $f->{'address'} = uri_escape($f->{'address'},'\x00-\x1f\x7f-\xff');
        $f->{'md5'} = md5_hex($f->{'address'});
        $f->{'sha1'} = sha1_hex($f->{'address'});
    }
    my $source = $f->{'source'};
    my ($err,$id) = $bucket->insert($f);
    ## TODO -- setup a mailer that returns this in cif_feed_parser
    warn($err) unless($id);
    
    my $rid;
    if($id =~ /^\d+$/){
        $rid = $id->description().' -- '.$id->uuid();
    } else {
        $rid = $id;
    }
    $a = substr($a,0,40);
    $a .= '...';
    print $source.' -- '.$rid.' -- '.$f->{'impact'}.' '.$f->{'description'}.' -- '.$a."\n";
    return(0);
}

sub insert {
    my ($full,@recs) = (shift,@_);
    #my $goback = DateTime->from_epoch(epoch => (time() - (84600 * 5)));
    #$goback = $goback->ymd().'T'.$goback->hms().'Z';
#    @recs = _sort_detecttime(@recs);

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
    #foreach(@recs){
    #    unless($full){
    #        next if(($_->{'detecttime'} cmp $goback) == -1);
    #    }
    #    _insert($_);
    #}
    foreach (@recs){
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
    return($cores * 1.5);
}

sub _split_batches {
    my $config = shift;
    my @recs = @_;
    my $tc = $config->{'threads_count'};
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
    delete($config->{'threads_count'});
    return(\@batches);
}

sub t_insert {
    my ($full,$fctn,$config,@recs) = (shift,shift,shift,@_);
    $fctn = 'CIF::FeedParser::insert' unless($fctn);
    @recs = _sort_detecttime(@recs);
    my $batches;
    if($full){ 
        $batches = _split_batches($config,@recs);
    } else {
        my $goback = DateTime->from_epoch(epoch => (time() - (84600 * 5)));
        $goback = $goback->ymd().'T'.$goback->hms().'Z';
        my @rr;
        foreach (@recs){
            last if(($_->{'detecttime'} cmp $goback) == -1);
            push(@rr,$_);
        }
        $batches = _split_batches($config,@rr);
    }
       
    # don't thread me out if we only have one batch
    # Crypt::SSLeay is NOT really thread safe, so we do simple https feeds with 1 bath where possible
    return insert($full,@recs) unless(scalar @{$batches} > -1);
    # go nuts...
    foreach(@{$batches}){
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

Copyright (C) 2011 by Wes Young (claimid.con/wesyoung)
Copyright (C) 2011 by REN-ISAC and The Trustees of Indiana University

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
