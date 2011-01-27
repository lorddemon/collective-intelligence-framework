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
    $self->{'silent'} = $cfg->{'silent'};
    
    if($args->{'fields'}){
        @{$self->{'fields'}} = split(/,/,$args->{'fields'}); 
    }

    return($self);
}

sub GET  {
    my ($self,$q,$s,$r,$silent) = @_;

    my $rest = '/'.$q.'?apikey='.$self->apikey();
    my $severity = ($s) ? $s : $self->{'severity'};
    my $restriction = ($r) ? $r : $self->{'restriction'};
    $silent = ($silent) ? $silent : $self->{'silent'};

    $rest .= '&severity='.$severity if($severity);
    $rest .= '&restriction='.$restriction if($restriction);
    $rest .= '&silent='.$silent if($silent);

    $self->SUPER::GET($rest);
    my $content = $self->{'_res'}->{'_content'};
    return unless($content);
    return unless($self->responseCode == 200);
    my $text = $self->responseContent();
    my $json = from_json($content, {utf8 => 1});
    if(my $sha1 = $json->{'data'}->{'result'}->{'hash_sha1'}){
        my $r = $json->{'data'}->{'result'}->{'feed'};
        die("sha1's don't match, possible data corruption... try again") unless($sha1 eq sha1_hex($r));
        $r = uncompress(decode_base64($r));
        $json->{'data'}->{'result'}->{'feed'} = from_json($r);
        $self->{'_res'}->{'_content'} = to_json($json);
    }
}       

sub table {
    my $self = shift;
    my $resp = shift;

    my $hash = from_json($resp);
    return 0 unless($hash->{'data'}->{'result'});
    $hash = $hash->{'data'}->{'result'};
    my $created = $hash->{'created'};
    my $feedid = $hash->{'id'};
    my @a = @{$hash->{'feed'}->{'items'}};
    return(undef,'invalid json input') unless($#a > -1);
    my @cols = (
        'restriction',
        'severity',
    );
    if(exists($a[0]->{'hash_md5'})){
        push(@cols,('hash_md5','hash_sha1'));
    } elsif(exists($a[0]->{'url_md5'})){
        push(@cols,('url_md5','url_sha1','malware_md5','malware_sha1'));
    } elsif(exists($a[0]->{'rdata'})) {
        push(@cols,('address','rdata','type'));
    } else {
        push(@cols,'address','portlist');
    }
    push(@cols,(
        'detecttime',
        'description',
        'alternativeid_restriction',
        'alternativeid',
    ));
    if($self->{'fields'}){
        @cols = @{$self->{'fields'}};
    }
    if(my $c = $self->{'config'}->{'display'}){
        @cols = @$c;
    }

    my @header = map { $_, { is_sep => 1, title => '|' } } @cols;
    pop(@header);
    my $table = Text::Table->new(@header);

    my @sorted = sort { $a->{'detecttime'} cmp $b->{'detecttime'} } @a;
    if(my $max = $self->{'max_desc'}){
        map { $_->{'description'} = substr($_->{'description'},0,$max) } @sorted;
    }
    foreach my $r (@sorted){
        $table->load([ map { $r->{$_} } @cols]);
    }
    if($created){
        $table = "Feed Created: ".$created."\n\n".$table;
    }
    if(my $r = $hash->{'feed'}->{'restriction'}){
        $table = "Feed Restriction: ".$r."\n".$table;
    }
    if(my $s = $hash->{'feed'}->{'severity'}){
        $table = 'Feed Severity: '.$s."\n".$table;
    }
    if($feedid){
        $table = 'Feed Id: '.$feedid."\n".$table;
    }
    return "\n".$table;
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

Copyright (C) 2010 REN-ISAC and The Trustees of Indiana University 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
