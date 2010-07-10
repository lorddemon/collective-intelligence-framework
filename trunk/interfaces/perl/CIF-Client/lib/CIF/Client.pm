package CIF::Client;
use base 'REST::Client';

use 5.008008;
use strict;
use warnings;
use JSON;
use Text::Table;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

# Preloaded methods go here.

sub new {
    my ($class,$args) = @_;
    my $self = REST::Client->new($args);
    bless($self,$class);

    $self->apikey($args->{'apikey'});
    $self->format($args->{'format'});
    return($self);
}

sub search {
    my ($self,$q,$fmt) = @_;
    $fmt = $self->format() unless($fmt);

    my $type;
    for($q){
        if(/^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/){
            $type = 'inet';
            last;
        }
        if(/^\d+$/){
            $type = 'asn';
            last;
        }
        if(/\w+@\w+/){
            $type = 'email';
            last;
        }
        if(/\w+\.\w+/){
            $type = 'domain';
            last;
        }
        if(/^[a-fA-F0-9]{32,40}$/){
            $type = 'malware';
            last;
        }
        if(/^url:([a-fA-F0-9]{32,40})$/){
            $type = 'url';
            $q = $1;
            last;
        }
        if(/^\S+$/){
            $type = 'impact';
            last;
        }
    }

    $self->type($type);

    $self->GET('/search/'.$type.'/'.$q.'?apikey='.$self->apikey().'&format='.$fmt);
}

sub table {
    my $self = shift;
    my $resp = shift;
    
    my @a = @{from_json($resp)};
    return('invalid json input') unless($#a > -1);
    my @cols = (
        'restriction',  { is_sep => 1, title => '|', },
        'impact',       { is_sep => 1, title => '|', },
        'description',  { is_sep => 1, title => '|', },
        'detecttime',   { is_sep => 1, title => '|', },
        'reference'
    );

    # test to see if 'address' key is in here
    if(exists($a[0]->{'address'})){
        push(@cols,{ is_sep => 1, title => '|' },'address');
    }
    my $table = Text::Table->new(@cols);

    foreach (@a){
        if(exists($_->{'address'})){
            $table->load([
                $_->{'restriction'},
                $_->{'impact'},
                $_->{'description'},
                $_->{'detecttime'},
                $_->{'reference'},
                $_->{'address'},
            ]);
       } else {
            $table->load([
                $_->{'restriction'},
                $_->{'impact'},
                $_->{'description'},
                $_->{'detecttime'},
                $_->{'reference'}
            ]);
        }
    }
    return $table;
}

sub type {
    my ($self,$v) = @_;
    $self->{_type} = $v if(defined($v));
    return($self->{_type});
}

sub format {
    my ($self,$v) = @_; 
    $self->{_format} = $v if(defined($v));
    return($self->{_format});
}

sub apikey {
    my ($self,$v) = @_;
    $self->{_apikey} = $v if(defined($v));
    return($self->{_apikey});
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
    timeout     => 10,
    apikey      => $apikey,
    format      => $format,
  });

  $client->search($query,$format);
  die('request failed with code: '.$client->responseCode()) unless($client->responseCode == 200);

  my $text = $client->responseContent();

  my @lines = split(/\n/,$text);

  if($format eq 'json'){
    print $client->table($lines[2]);
  } else {
    foreach (@lines){
        print $_."\n"
    }
  }
 

=head1 DESCRIPTION

Simple extension of REST::Client for use with the CI-Framework REST based interface. Implements apikeys support and sample table output.

=head1 SEE ALSO

CIF::DBI, REST::Client, RT-CIF

http://code.google.com/p/collective-intelligence-framework/

Wes Young, E<lt>wes@barely3am.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Wes Young

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
