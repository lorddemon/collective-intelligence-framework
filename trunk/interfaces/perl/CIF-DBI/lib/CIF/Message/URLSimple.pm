package CIF::Message::URLSimple;
use base 'CIF::Message::URL';

use strict;
use warnings;

use CIF::Message::MalwareURL;
use CIF::Message::PhishingURL;

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    my $bucket = 'CIF::Message::MalwareURL';
    my $impact = 'malware url';
    my $description = $info->{'description'};
    if($description =~ /phish/){
        $bucket = 'CIF::Message::PhishingURL';
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
