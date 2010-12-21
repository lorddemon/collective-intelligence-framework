package CIF::Message::UrlSimple;
use base 'CIF::Message::Url';

use strict;
use warnings;

use CIF::Message::UrlMalware;
use CIF::Message::UrlPhishing;

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    my $bucket = 'CIF::Message::UrlMalware';
    my $impact = 'malware url';
    my $description = $info->{'description'};
    if($description =~ /phish/){
        $bucket = 'CIF::Message::UrlPhishing';
        $impact = 'phishing url';
    }

    my $id = $bucket->insert({
        relatedid   => $info->{'relatedid'},
        address     => $info->{'address'},
        source      => $info->{'source'},
        confidence  => $info->{'confidence'},
        severity    => $info->{'severity'},
        impact      => $impact,
        description => $description,
        malware_md5 => $info->{'malware_md5'},
        malware_sha1 => $info->{'malware_sha1'},
        detecttime  => $info->{'detecttime'},
        restriction => $info->{'restriction'} || 'private',
        alternativeid => $info->{'alternativeid'},
        alternativeid_restriction => $info->{'alternativeid_restriction'},
    });
    return $id;
}

1;
