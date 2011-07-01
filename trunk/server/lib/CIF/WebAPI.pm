package CIF::WebAPI;
use base 'Apache2::REST::Handler';

use strict;
use warnings;

require CIF::WebAPI::APIKey;
use DateTime;
use DateTime::Format::DateParse;
require CIF::Archive;
use Digest::SHA1 qw/sha1_hex/;
use Data::Dumper;

use Module::Pluggable require => 1, except => qr/::Plugin::\S+::/;

sub isAuth {
    my ($self,$meth,$req) = @_;
    return(1) if($meth eq 'GET');
    my $key = lc($req->param('apikey'));
    my $rec = CIF::WebAPI::APIKey->retrieve(apikey => $key);
    return(0) unless($rec && $rec->write());
    my $src = $rec->userid();
    $src = CIF::Archive::genSourceUUID($src);
    $self->{'source'} = $src;
    return(1);
}

sub map_restrictions {
    my ($self,$req,$res,@feed) = @_;
    my $nomap = $req->{'r'}->param('nomap');
    return($res,@feed) if($nomap);

    if(my %m = $req->{'r'}->dir_config->get('CIFRestrictionMap')){
        foreach my $r (keys %m){
            $res = $m{$r} if(lc($res) eq lc($r));
        }
        warn Dumper(@feed);
        foreach (@feed){
            my $r = lc($_->{'Incident'}->{'restriction'});
            my $ar = lc($_->{'Incident'}->{'AlternativeID'}->{'IncidentID'}->{'restriction'});

            $_->{'Incident'}->{'restriction'} = $m{$r} if(exists($m{$r}));
            $_->{'Incident'}->{'AlternativeID'}->{'IncidentID'}->{'restriction'} = $m{$ar} if(exists($m{$ar}));
        }
    }
    return ($res,@feed);
}

sub GET {
    my ($self,$request,$response) = @_;

    unless($request->{'r'}->param('fmt')){
        my $agent = $request->{'r'}->headers_in->{'User-Agent'};
        if(lc($agent) =~ /(mozilla|msie|chrome|safari)/){
            $request->requestedFormat('table');
            if(my $f = $request->{'r'}->param('fields')){
                $response->{'fields'} = $f;
            }
        }
    }

    my $maxresults = $request->{'r'}->param('maxresults') || $request->dir_config->{'CIFFeedResultsDefault'} || 10000;
    my $apikey = $request->{'r'}->param('apikey');

    # figure out who's calling us
    my @bits    = split(/\:\:/,ref($self));
    my $impact  = lc($bits[$#bits]);
    my $type    = lc($bits[$#bits-1]);
    if($type eq 'plugin'){
        $type = $impact;
        $impact = '';
    }

    my $nolog = $request->{'r'}->param('nolog');
    my $restriction = $request->{'r'}->param('restriction') || $request->{'r'}->dir_config->get('CIFDefaultFeedRestriction') || 'need-to-know';
    my $q = $self->{'query'};
    if($q && $q =~ /^ERROR/){
        $response->{'message'} = $q;
        return Apache2::Const::HTTP_OK;
    }

    ## TODO -- clean this up
    my $no_restriction_map = $request->{'r'}->param('nomap');

    if(!$no_restriction_map && (my %m = $request->{'r'}->dir_config->get('CIFRestrictionMap'))){
        foreach (keys %m){
            $restriction = $_ if(lc($m{$_}) eq lc($restriction));
        }
    }

    my $feed;
    if($q){
        $restriction = 'private';
        my $severity = $request->{'r'}->param('severity') || 'null';
        my $confidence = $request->{'r'}->param('confidence') || 0;
        my $ret = CIF::Archive->lookup({ nolog => $nolog, query => $q, source => $apikey, severity => $severity, restriction => $restriction, max => $maxresults, confidence => $confidence });
        return Apache2::Const::HTTP_OK unless($ret);
        my @recs;
        if(ref($ret) ne 'CIF::Archive'){
            @recs = $ret->slice(0,$ret->count());
            @recs = map { $_ = $_->uuid->data_hash() } @recs;
        } else {
            $ret = $ret->data_hash();
            push(@recs,$ret);
        }
        ($restriction,@recs) = $self->map_restrictions($request,$restriction,@recs);
        my $dt = DateTime->from_epoch(epoch => time());
        my $f = {
            entry => \@recs,
            restriction => $restriction,
            source      => sha1_hex($apikey),
            description => 'search '.$q,
            detecttime  => $dt->ymd().'T'.$dt->hms().'Z',
        };
        $feed->{'feed'} = $f;
    } else {
        ## TODO -- clean this up
        $q = lc($type);
        $q = lc($impact).' '.$q if($impact);
        my $severity = $request->{'r'}->param('severity') || $request->{'r'}->dir_config->get('CIFDefaultFeedSeverity') || 'high';
        my $confidence = $request->{'r'}->param('confidence') || $request->{'r'}->dir_config->get('CIFDefaultFeedConfidence') || 85;
        my $ret = CIF::Archive->lookup({ nolog => $nolog, query => $q, source => $apikey, severity => $severity, restriction => $restriction, max => $maxresults, confidence => $confidence });
        return Apache2::Const::HTTP_OK unless($ret);

        # we do it with @recs cause of the map_restrictions function
        my @recs = $ret->slice(0,$ret->count());
        my $uuid = $recs[0]->uuid->uuid();
        @recs = map { $_ = $_->uuid->data_hash() } @recs;
        

        my $old_restriction = $restriction;
        ($restriction,@recs) = $self->map_restrictions($request,$restriction,@recs);

        my $f;
        $f->{'id'} = $uuid;
        $f->{'entry'} = [$recs[0]->{'data'}];
        $f->{'restriction'} = $restriction;
        $f->{'description'} = $recs[0]->{'description'};
        $f->{'detecttime'} = $recs[0]->{'detecttime'};

        # don't laugh. it was hard to write this.
        $f->{'description'} =~ s/$old_restriction/$restriction/ if($f->{'description'});
        $feed->{'feed'} = $f;
    }
    $response->{'data'} = $feed;

    return Apache2::Const::HTTP_OK;
}


sub buildNext {
    my ($self,$frag,$req) = @_;
    $frag = lc($frag);

    if(CIF::Archive::isUUID($frag)){
        $self->{'query'} = $frag;
        return($self);
    }

    my @plugins = grep(!/SUPER$/,$self->plugins());
    foreach(@plugins){
        if($_->prepare($frag)){
            my $h = $_->new($self);
            return($h->buildNext($frag,$req));
        }
    }
    return $self->SUPER::buildNext($frag,$req);
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::WebAPI - Perl extension for providing an extendable REST based API to the Collective Intelligence Framework

=head1 SYNOPSIS

  <Location /api>
    SetHandler perl-script
    PerlSetVar Apache2RESTHandlerRootClass "CIF::WebAPI::Plugin"
    PerlSetVar Apache2RESTAPIBase "/api"
    PerlResponseHandler Apache2::REST
    PerlSetVar Apache2RESTWriterDefault 'json'
    PerlSetVar Apache2RESTAppAuth 'CIF::WebAPI::AppAuth'

    PerlSetVar CIFFeedResultsDefault 10000
    PerlSetVar CIFDefaultFeedSeverity "high"
    PerlSetVar CIFDefaultFeedRestriction 'need-to-know'

    PerlAddVar Apache2RESTWriterRegistry 'table'
    PerlAddVar Apache2RESTWriterRegistry 'CIF::WebAPI::Writer::table'
  </Location>

=head1 SEE ALSO

 http://code.google.com/p/collective-intelligence-framework/
 CIF::WebAPI::Writer::iodef
 CIF::WebAPI::Writer::atom

=head1 AUTHOR

Wes Young, E<lt>wes@barely3am.comE<gt>

=head1 COPYRIGHT AND LICENSE

 Copyright (C) 2011 by Wes Young (claimid.com/wesyoung)
 Copyright (C) 2011 by the Trustee's of Indiana University (www.iu.edu)
 Copyright (C) 2011 by the REN-ISAC (www.ren-isac.net)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
