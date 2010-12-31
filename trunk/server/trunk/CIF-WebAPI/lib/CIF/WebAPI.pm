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
    my ($self,$request,$response) = @_;

    unless($request->{'r'}->param('fmt')){
        my $agent = $request->{'r'}->headers_in->{'User-Agent'};
        if(lc($agent) =~ /(mozilla|msie|chrome|safari)/){
            $request->requestedFormat('table');
        }
    }

    my $maxresults = $request->{'r'}->param('maxresults') || $request->dir_config->{'CIFFeedResultsDefault'} || 10000;
    my $apikey = $request->{'r'}->param('apikey');

    # figure out who's calling us
    my @bits    = split(/\:\:/,ref($self));
    my $impact  = ucfirst($bits[$#bits]);
    my $type    = ucfirst($bits[$#bits-1]);
    if($type eq 'WebAPI'){
        $type = $impact;
        $impact = '';
    }
    
    my $created = DateTime->from_epoch(epoch => time());
    # see if we have that method
    my $bucket = 'CIF::Message::Feed'.$type.$impact;
    eval "require $bucket";
    if($@){
        warn $@;
        return Apache2::Const::FORBIDDEN;
    }

    my $msg;
    if(my $q = $self->{'query'}){
        my $qbucket = 'CIF::Message::'.$type;
        eval "require $qbucket";
        if($@){
            warn $@;
            return Apache2::Const::FORBIDDEN;
        }
        
        my @recs = $qbucket->lookup($q,$apikey,$maxresults);
        unless(@recs){ return Apache2::Const::HTTP_OK; }
        my $res;
        @recs = map { $bucket->mapIndex($_) } @recs;
        ($res,@recs) = $self->map_restrictions($request,'private',@recs);
        @{$msg->{'items'}} = @recs;
        $msg->{'restriction'} = $res;
    } else {
        my $restriction = $request->{'r'}->param('restriction') || 'private';
        if($restriction){
            if(my %m = $request->{'r'}->dir_config->get('CIFRestrictionMap')){
                foreach (keys %m){
                    $restriction = $_ if(lc($m{$_}) eq lc($restriction));
                }
            }
        }

        my $severity = $request->{'r'}->param('severity') || 'high';

        my @recs = $bucket->search(severity => $severity, restriction => $restriction, { order_by => 'id DESC', limit => 1 });
        return Apache2::Const::HTTP_OK if($#recs == -1);
        
        ($restriction,@recs) = $self->map_restrictions($request,$restriction,@recs);

        $msg = $recs[0]->message();
        $response->{'data'}->{'result'}->{'hash_sha1'} = sha1_hex($msg);
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
        }
        foreach (@feed){
            my $r = lc($_->{'restriction'});
            my $ar = lc($_->{'alternativeid_restriction'});

            $_->{'restriction'} = $m{$r} if(exists($m{$r}));
            $_->{'alternativeid_restriction'} = $m{$ar} if(exists($m{$ar}));
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
