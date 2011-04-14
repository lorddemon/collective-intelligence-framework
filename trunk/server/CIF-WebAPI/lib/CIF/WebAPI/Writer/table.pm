package CIF::WebAPI::Writer::table;
use strict;
use warnings;

use Text::Table;
use JSON;
use MIME::Base64;
use Compress::Zlib;
use Encode qw/encode_utf8/;
use Data::Dumper;

=head1 NAME

Apache2::REST::Writer::json - Apache2::REST::Response Writer for json

=cut

=head2 new

=cut

sub new{
    my ( $class ) = @_;
    return bless {} , $class;
}

=head2 mimeType

Getter

=cut

sub mimeType {
    return 'text/plain';
}

=head2 asBytes

Returns the response as json UTF8 bytes for output.

=cut

sub asBytes{
    my ($self,  $resp ) = @_ ;
    
    return $resp->{'message'} if($resp->{'message'});
    return 'no records, check back later' unless($resp->{'data'});
    my $hash = $resp->{'data'};
    if($hash->{'hash_sha1'}){
        warn from_json($hash->{'feed'});
        $hash->{'feed'} = from_json(uncompress(decode_base64($hash->{'feed'})));
    }
    my @array = @{$hash->{'feed'}->{'items'}};

    my @cols;
    if(my $f = $resp->{'fields'}){
        @cols = split(/,/,$f);
    } else {
        @cols = (
            'restriction',
            'asn',
            'asn_desc',
            'cidr',
            'address',
        );
        if(exists($array[0]->{'rdata'})){
            push(@cols,'type');
            push(@cols,'rdata');
        } elsif(exists($array[0]->{'url_md5'})){
            push(@cols,(
                    'url_md5',
                    'url_sha1',
                    'malware_md5',
                    'malware_sha1'
                )
            );
        } elsif(exists($array[0]->{'hash_md5'})){
            push(@cols,(
                    'hash_md5',
                    'hash_sha1',
                )
            );
        } else {
            push(@cols,'portlist');
        }
        push(@cols,(
                'description',
                'severity',
                'detecttime',
                'created',
                'alternativeid_restriction',
                'alternativeid'
            )
        );
    }
    my @header;
    foreach (@cols){
         push(@header,($_,{ is_sep => 1, title => '|', }));
    }
    pop(@header);
    my $t = Text::Table->new(@header);
    foreach my $r (@array){
        if(exists($r->{'asn_desc'})){
            $r->{'asn_desc'} = substr($r->{'asn_desc'},0,40) if($r->{'asn_desc'});
        }
        $t->load([map { $r->{$_} } @cols]);
    }
    if(my $c = $hash->{'created'}){
        $t = 'Feed Created: '.$c."\n\n".$t;
    }
    if(my $r = $hash->{'feed'}->{'restriction'}){
        $t = 'Feed Restriction: '.$r."\n".$t;
    }
    if(my $s = $hash->{'feed'}->{'severity'}){
        $t = 'Feed Severity: '.$s."\n".$t;
    }
    if(my $feedid = $hash->{'id'}){
        $t = 'Feed Id: '.$feedid."\n".$t;
    }
    return(Encode::encode_utf8($t));
}

1;
