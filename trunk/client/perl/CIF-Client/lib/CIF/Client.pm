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
use Module::Pluggable search_path => ['CIF::Client::Plugin'], require => 1, except => qr/Plugin::\S+::/;
use URI::Escape;

__PACKAGE__->mk_accessors(qw/apikey config/);

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

# Preloaded methods go here.

sub _plugins {
    my @plugs = plugins();
    foreach (@plugs){
        next unless($_->type eq 'output');
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
    $self->{'simple_hashes'} = $args->{'simple_hashes'} || $cfg->{'simple_hashes'};
    
    if($args->{'fields'}){
        @{$self->{'fields'}} = split(/,/,$args->{'fields'}); 
    }

    return($self);
}

sub GET  {
    my $self = shift;
    my %args = @_;

    my $q = $args{'query'};
    if(lc($q) =~ /^http(s)?:\/\//){
        ## escape unsafe chars, that's what the data-warehouse does
        ## TODO -- doc this
        $q = uri_escape($q,'\x00-\x1f\x7f-\xff');
        $q = lc($q);
        $q = sha1_hex($q);
    }
    my $rest = '/'.$q.'?apikey='.$self->apikey();
    my $severity = ($args{'severity'}) ? $args{'severity'} : $self->{'severity'};
    my $restriction = ($args{'restriction'}) ? $args{'restriction'} : $self->{'restriction'};
    my $nolog = ($args{'nolog'}) ? $args{'nolog'} : $self->{'nolog'};
    my $nomap = ($args{'nomap'}) ? $args{'nomap'} : $self->{'nomap'};
    my $confidence = ($args{'confidence'}) ? $args{'confidence'} : $self->{'confidence'};

    $rest .= '&severity='.$severity if($severity);
    $rest .= '&restriction='.$restriction if($restriction);
    $rest .= '&nolog='.$nolog if($nolog);
    $rest .= '&nomap=1' if($nomap);
    $rest .= '&confidence='.$confidence if($confidence);

    $self->SUPER::GET($rest);
    my $content = $self->{'_res'}->{'_content'};
    warn $content if($::debug);
    return unless($content);
    return unless($self->responseCode == 200);
    my $text = $self->responseContent();
    my $hash = from_json($content, {utf8 => 1});
    my $t = ref(@{$hash->{'data'}->{'feed'}->{'entry'}}[0]);
    unless($t eq 'HASH'){
        my $r = @{$hash->{'data'}->{'feed'}->{'entry'}}[0];
        return unless($r);
        $r = uncompress(decode_base64($r));
        $r = from_json($r);
        $hash->{'data'}->{'feed'}->{'entry'} = $r;
    }
    ## TODO -- finish implementing this into the config
    if($self->{'simple_hashes'}){
        $self->hash_simple($hash);
    }
    return($hash->{'data'});
}       

sub hash_simple {
    my $self = shift;
    my $hash = shift;
    my @entries = @{$hash->{'data'}->{'feed'}->{'entry'}};

    my @plugs = $self->plugins();
    my @a;
    foreach (@plugs){
        next if(/Parser$/);
        push(@a,$_) if($_->type eq 'parser');
    }
    @plugs = @a;
    my @return;
    foreach my $p (@plugs){
        foreach my $e (@entries){
            if($p->prepare($e)){
                my @ary = @{$p->hash_simple($e)};
                push(@return,@ary);
            } else {
                push(@return,$e);
            }
        }
    }
    return unless(@return);
    @{$hash->{'data'}->{'feed'}->{'entry'}} = @return;
    return($hash);
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
