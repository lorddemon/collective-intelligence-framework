package CIF::WebAPI;
use base 'Apache2::REST::Handler';

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.01_03';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use CIF::WebAPI::APIKey;
use JSON;
use DateTime;
use DateTime::Format::DateParse;
use CIF::Archive;
use Digest::SHA1 qw/sha1_hex/;

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
    my $severity = $request->{'r'}->param('severity') || $request->{'r'}->dir_config->get('CIFDefaultFeedSeverity') || 'high';
    my $restriction = $request->{'r'}->param('restriction') || $request->{'r'}->dir_config->get('CIFDefaultFeedRestriction') ||'private';
    my $q = $self->{'query'};
    if($q && $q =~ /^ERROR/){
        $response->{'message'} = $q;
        return Apache2::Const::HTTP_OK;
    }

    if(my %m = $request->{'r'}->dir_config->get('CIFRestrictionMap')){
        foreach (keys %m){
            $restriction = $_ if(lc($m{$_}) eq lc($restriction));
        }
    }

    my $feed;
    if($q){
        $restriction = 'private';
        my $ret = CIF::Archive->lookup({ nolog => $nolog, query => $q, source => $apikey, severity => $severity, restriction => $restriction, max => $maxresults });
        return Apache2::Const::HTTP_OK unless(@$ret);
        my @recs = @$ret;
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
        $q = lc($type);
        $q .= ' '.lc($impact) if($impact);
        my $ret = CIF::Archive->lookup({ nolog => $nolog, query => $q, source => $apikey, severity => $severity, restriction => $restriction, max => $maxresults });
        return Apache2::Const::HTTP_OK unless(@$ret);

        my @recs = @$ret;
        ($restriction,@recs) = $self->map_restrictions($request,$restriction,@recs);

        my $f = from_json($recs[0]->{'data'});
        $f->{'id'} = $recs[0]->{'uuid'};
        $f->{'entry'} = [$f->{'data'}];
        delete($f->{'data'});
        $feed->{'feed'} = $f;
    }
    $response->{'data'} = $feed;

    return Apache2::Const::HTTP_OK;
}


sub buildNext {
    my ($self,$frag,$req) = @_;
    $frag = lc($frag);

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
