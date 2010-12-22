package CIF::Client;
use base 'REST::Client';
use base qw(Class::Accessor);

use 5.008008;
use strict;
use warnings;

use JSON;
use Text::Table;
use File::Type;
use Config::Simple;
use Compress::Zlib;
use Data::Dumper;
use Digest::SHA1 qw/sha1_hex/;
__PACKAGE__->mk_accessors(qw/apikey format/);

our $VERSION = '0.00_03';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

# Preloaded methods go here.

sub new {
    my $class = shift;
    my $args = shift;

    my $cfg = Config::Simple->new($args->{'config'}) || return(undef,'missing config file');
    $cfg = $cfg->param(-block => 'client');

    my $apikey = $args->{'apikey'} || $cfg->{'apikey'} || return(undef,'missing apikey');
    my $fmt = $args->{'format'} || $cfg->{'format'} || 'json';
    unless($args->{'host'}){
        $args->{'host'} = $cfg->{'host'} || return(undef,'missing host');
    }

    my $self = REST::Client->new($args);
    bless($self,$class);

    $self->{'apikey'} = $apikey;
    $self->{'config'} = $cfg;

    return($self);
}

sub GET  {
    my ($self,$q,$s,$r) = @_;

    my $rest = '/'.$q.'?apikey='.$self->apikey();
    $rest .= '&severity='.$s if($s);
    $rest .= '&restriction='.$r if($r);

    $self->SUPER::GET($rest);
    my $content = $self->{'_res'}->{'_content'};
    return unless($content);
    my $ft = File::Type->new();
    my $type = $ft->mime_type($content);
    if($type =~ /gzip/){
        $content = Compress::Zlib::memGunzip($content);
        $self->{'_res'}->{'_content'} = $content;
    }
    my $text = $self->responseContent();
    my $json = from_json($content, {utf8 => 1});
    if(my $r = $json->{'data'}->{'result'}){
        $type = $ft->mime_type($r);
        if($type =~ /gzip/){
            my $sha1 = $json->{'data'}->{'hash_sha1'};
            die("sha1's don't match, possible data corruption... try again") unless($sha1 eq sha1_hex($r));
            $r = Compress::Zlib::memGunzip($r);
            $json->{'data'}->{'result'} = from_json($r);
            $self->{'_res'}->{'_content'} = to_json($json);
        }
    }
}       

sub table {
    my $self = shift;
    my $resp = shift;

    my $hash = from_json($resp);
    return 0 unless($hash->{'data'}->{'result'});
    my @a = @{$hash->{'data'}->{'result'}};
    return(undef,'invalid json input') unless($#a > -1);
    my @cols = (
        'address',
        'severity',
        'detecttime',
        'restriction',
        'description',
        'alternativeid'
    );
    if(my $c = $self->{'config'}->{'display'}){
        @cols = @$c;
    }

    my @header = map { $_, { is_sep => 1, title => '|' } } @cols;
    pop(@header);
    my $table = Text::Table->new(@header);

    my @sorted = sort { $a->{'detecttime'} cmp $b->{'detecttime'} } @a;
    foreach my $r (@sorted){
        $table->load([ map { $r->{$_} } @cols]);
    }
    if(my $created = $hash->{'data'}->{'created'}){
        $table = "Feed Created: ".$created."\n\n".$table;
    }
    return $table;
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
