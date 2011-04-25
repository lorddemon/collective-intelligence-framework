package CIF::Client;
use base 'REST::Client';
use base qw(Class::Accessor);

use 5.008008;
use strict;
use warnings;

use JSON;
use Text::Table;
use Config::Simple;
use Compress::Zlib;
use Data::Dumper;
use Encode qw/decode_utf8/;
use Digest::SHA1 qw/sha1_hex/;
use MIME::Base64;
use Module::Pluggable search_path => ['CIF::Client::Plugin'];

__PACKAGE__->mk_accessors(qw/apikey config/);

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

# Preloaded methods go here.

sub _plugins {
    my @plugs = plugins();
    foreach (@plugs){
        $_ =~ s/CIF::Client::Plugin:://;
        $_ = lc($_);
    }
    return (@plugs);
}

sub new {
    my $class = shift;
    my $args = shift;

    my $cfg = Config::Simple->new($args->{'config'}) || return(undef,'missing config file');
    $cfg = $cfg->param(-block => 'client');

    my $apikey = $args->{'apikey'} || $cfg->{'apikey'} || return(undef,'missing apikey');
    unless($args->{'host'}){
        $args->{'host'} = $cfg->{'host'} || return(undef,'missing host');
    }

    my $self = REST::Client->new($args);
    bless($self,$class);

    $self->{'apikey'} = $apikey;
    $self->{'config'} = $cfg;
    $self->{'max_desc'} = $args->{'max_desc'};
    $self->{'restriction'} = $cfg->{'restriction'};
    $self->{'severity'} = $cfg->{'severity'};
    $self->{'nolog'} = $cfg->{'nolog'};
    
    if($args->{'fields'}){
        @{$self->{'fields'}} = split(/,/,$args->{'fields'}); 
    }

    return($self);
}

sub GET  {
    my ($self,$q,$s,$r,$nolog) = @_;

    if(lc($q) =~ /^http(s)?:\/\//){
        $q = 'url/'.sha1_hex($q);
    }
    my $rest = '/'.$q.'?apikey='.$self->apikey();
    my $severity = ($s) ? $s : $self->{'severity'};
    my $restriction = ($r) ? $r : $self->{'restriction'};
    $nolog = ($nolog) ? $nolog : $self->{'nolog'};

    $rest .= '&severity='.$severity if($severity);
    $rest .= '&restriction='.$restriction if($restriction);
    $rest .= '&nolog='.$nolog if($nolog);

    $self->SUPER::GET($rest);
    my $content = $self->{'_res'}->{'_content'};
    return unless($content);
    return unless($self->responseCode == 200);
    my $text = $self->responseContent();
    my $hash = from_json($content, {utf8 => 1});
    my $t = ref(@{$hash->{'data'}->{'feed'}->{'entry'}}[0]) || '';
    unless($t eq 'HASH'){
        my $r = @{$hash->{'data'}->{'feed'}->{'entry'}}[0];
        return unless($r);
        $r = uncompress(decode_base64($r));
        $r = from_json($r);
        $hash->{'data'}->{'feed'}->{'entry'} = $r;
        ## TODO -- do we really need to do this?
        #$self->{'_res'}->{'_content'} = to_json($hash);
    }
    return($hash->{'data'});
}       

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::Client - Perl extension that extends REST::Client for use with the CI-Framework REST interface 

=head1 SYNOPSIS

  use CIF::Client;
  my $client = CIF::Client->new({
    host        => $url,
    timeout     => 60,
    apikey      => $apikey,
  });

  $client->search($query);
  die('request failed with code: '.$client->responseCode()) unless($client->responseCode == 200);

  my $text = $client->responseContent();

  print $client->table($text) || die('no records')

=head1 COMMAND-LINE

  $> cif -h
  $> cif -q example.com
  $> cif -q domain -p bindzone
  $> cif -q 192.168.1.0/24
  $> cif -q infrastructure/network -p snort
  $> cif -q url -s low | grep -v private

=head1 CONFIG FILE

Your config should be stored in ~/.cif (default)

  [client]
  host = https://example.com:443/api
  apikey = xx-xx-xx-xx-xx
  timeout = 60
  #severity = medium

=head1 DESCRIPTION

Simple extension of REST::Client for use with the CI-Framework REST based interface. Implements apikeys support and sample table output.

=head1 SEE ALSO

CIF::DBI, REST::Client

http://code.google.com/p/collective-intelligence-framework/

Wes Young, E<lt>wes@barely3am.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by REN-ISAC and The Trustees of Indiana University 
Copyright (C) 2010 by Wes Young

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
