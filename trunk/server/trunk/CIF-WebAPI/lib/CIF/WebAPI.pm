package CIF::WebAPI;
use base 'Apache2::REST::Handler';

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.00_02';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use CIF::Message::Structured;
use CIF::WebAPI::APIKey;
use JSON;
use Regexp::Common qw/net/;
use Digest::SHA1 qw/sha1_hex/;
use Encode qw/decode_utf8/;
use MIME::Base64;
use DateTime;
use DateTime::Format::DateParse;
use Data::Dumper;

sub POST {
    my ($self,$req,$resp,%args) = @_;
    
    # who's calling me
    my @bits = split(/\:\:/,ref($self));
    my $impact = $bits[$#bits];
    my $type = $bits[$#bits-1];
    if($type eq 'WebAPI'){
        return Apache2::Const::FORBIDDEN;
    }

    # see if we have this implemented
    my $bucket = 'CIF::WebAPI::'.$type;
    eval "require $bucket";
    my $f = '&CIF::WebAPI::'.$type.'::submit';
    if($@ || !defined($f)){
        $resp->{'message'} = $@ if($@);
        return Apache2::Const::FORBIDDEN;
    }

    my $json;
    $req->read($json,$req->headers_in->{'Content-Length'});
    my $h = from_json($json);
    $h->{'impact'} = $impact;

    my $handle = $bucket->new($self);
    my ($ret,$err) = $handle->submit(%$h);
    if($ret){
        $resp->data->{'result'} = $ret->uuid->id();
    } else {
        $resp->{'message'} = 'submission failed: '.$err;
    }
    return Apache2::Const::HTTP_OK;
}

sub isAuth {
    my ($self,$meth,$req) = @_;
    return(1) if($meth eq 'GET');
    my $key = lc($req->param('apikey'));
    my $rec = CIF::WebAPI::APIKey->retrieve(apikey => $key);
    return(0) unless($rec && $rec->write());
    my $src = $rec->userid();
    $src = CIF::Message::genSourceUUID($src);
    $self->{'source'} = $src;
    return(1);
}

sub GET {
    my ($self,$request,$response,@feed) = @_;

    unless($request->{'r'}->param('fmt')){
        my $agent = $request->{'r'}->headers_in->{'User-Agent'};
        if(lc($agent) =~ /(mozilla|msie|chrome|safari)/){
            $request->requestedFormat('table');
        }
    }
    my $msg;
    my $restriction = 'private';
    if(my $x = $request->{'r'}->param('restriction')){
        if(my %m = $request->{'r'}->dir_config->get('CIFRestrictionMap')){
            foreach (keys %m){
                $x = $_ if(lc($m{$_}) eq lc($x));
            }
            $restriction = $x;
        }
    }

    my $created = DateTime->from_epoch(epoch => time());
    if(@feed){
        my $res;
        ($res,@feed) = $self->map_restrictions($request,'private',@feed);
        use CIF::Message::FeedInfrastructure;
        my $f = CIF::Message::FeedInfrastructure->new();
        @feed = map { $f->mapIndex($_) } @feed;
        @{$msg->{'items'}} = @feed;
        $msg->{'restriction'} = $res;
    } else {
    my $severity = 'high';
    if(my $x = $request->{'r'}->param('severity')){
        $severity = $x;
    }

    # figure out who's calling us
    my @bits    = split(/\:\:/,ref($self));
    my $impact  = ucfirst($bits[$#bits]);
    my $type    = ucfirst($bits[$#bits-1]);
    if($type eq 'WebAPI'){
        $type = $impact;
        $impact = '';
    }

    # see if we have that method
    my $bucket = 'CIF::Message::Feed'.$type.$impact;
    eval "require $bucket";
    if($@){
        $response->{'message'} = $@ if($@);
        return Apache2::Const::FORBIDDEN;
    }
    
    my @recs = $bucket->search(severity => $severity, restriction => $restriction, { order_by => 'id DESC', limit => 1 });
    return Apache2::Const::HTTP_OK if($#recs == -1);
    ($restriction,@recs) = $self->map_restrictions($request,$restriction,@recs);
    
    $msg = $recs[0]->message();
    my $sha1 = sha1_hex($msg);;

    $response->{'data'}->{'result'}->{'hash_sha1'} = $sha1;
    $created = DateTime::Format::DateParse->parse_datetime($recs[0]->created());
    }

    $created = $created->ymd().'T'.$created->hms().'Z';
    $response->{'data'}->{'result'}->{'created'} = $created;
    $response->{'data'}->{'result'}->{'feed'} = $msg;
     
    return Apache2::Const::HTTP_OK;
}

sub map_restrictions {
    my ($self,$req,$res,@feed) = @_;

    if(my %m = $req->{'r'}->dir_config->get('CIFRestrictionMap')){
        foreach my $r (keys %m){
            $res = $m{$r} if(lc($res) eq lc($r));
            # map the restriction classes
            foreach (@feed){
                if(lc($_->restriction()) eq lc($r)){
                    $_->{'restriction'} = $m{$r};
             }
            }
        }
    }
    return ($res,@feed);
}

sub buildNext {
    my ($self,$frag,$req) = @_;
    $frag = lc($frag);

    foreach (qw/domain infrastructure malware email url/){
        eval 'require CIF::WebAPI::'.$_;
    }

    my $type;
    for($frag){
        if(/^url:/){
            $type = 'url';
            $frag =~ s/^url://;
            last;
        }
        if(/^($RE{'net'}{'IPv4'}|AS\d+)/){
            $type = 'infrastructure';
            last;
        }
        if(/^\w+@\w+/){
            $type = 'email';
            last;
        }
        if(/^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/){
            $type = 'domain';
            last;
        }
        if(/^[a-fA-F0-9]{32,40}$/){
            $type = 'malware';
            last;
        }
    }
    return $self->SUPER::buildNext($frag,$req) unless($type);
    my $bucket = 'CIF::WebAPI::'.$type;
    my $h = $bucket->new($self);
    return($h->buildNext($frag,$req));
}

sub cachedFeed {
    my ($self,$req,$resp) = @_;
    my $dir = $req->dir_config->{'CIFCacheDir'};
    my @bits = split(/\:\:/,ref($self));
    my $impact = $bits[$#bits-1];
    my $type = $bits[$#bits-2].'_';
    if($type eq 'WebAPI_'){
        $type = $impact;
        $impact = '';
    }
    my $feed = $type.$impact.'.feed';
    my $file = $dir.'/'.$feed;
    my $content = '';
    
    return Apache2::Const::HTTP_OK unless(-s $file);

    open(F,$dir.'/'.$feed) || return Apache2::Const::SERVER_ERROR;
    while(<F>){
        chomp();
        $content = $_;
    }
    close(F);
    $resp->data->{'result'} = from_json($content);
    return Apache2::Const::HTTP_OK;
}

sub aggregateFeed {
    my $key = shift;
    my @recs = @_;
    
    my $hash;
    my @feed;
    foreach (@recs){
        if(exists($hash->{$_->$key()})){
            if($_->restriction() eq 'private'){
                next unless($_->restriction() eq 'need-to-know');
            }
        }
        $hash->{$_->$key()} = $_;
    }
    foreach (keys %$hash){
        my $rec = $hash->{$_};
        push(@feed, mapIndex($rec));
    }
    return(\@feed);
}

sub mapIndex {
    my $rec = shift;
    my $msg = CIF::Message::Structured->retrieve(uuid => $rec->uuid->id());
    $msg = $msg->message();
    return {
        rec         => $rec,
        restriction => $rec->restriction(),
        severity    => $rec->severity(),
        impact      => $rec->impact(),
        confidence  => $rec->confidence(),
        description => $rec->description(),
        detecttime  => $rec->detecttime(),
        uuid        => $rec->uuid->id(),
        alternativeid   => $rec->alternativeid(),
        alternativeid_restriction   => $rec->alternativeid_restriction(),
        created     => $rec->created(),
        message     => $msg,
    };
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::WebAPI - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CIF::WebAPI;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for CIF::WebAPI, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Wes Young, E<lt>wes@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Wes Young
Copyright (C) 2010 by REN-ISAC and The Trustees of Indiana University 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
