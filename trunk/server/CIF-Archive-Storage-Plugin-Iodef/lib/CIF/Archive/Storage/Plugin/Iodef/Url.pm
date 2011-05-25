package CIF::Archive::Storage::Plugin::Iodef::Url;

use Regexp::Common qw /URI/;
use URI::Escape;

sub prepare {
    my $class   = shift;
    my $info    = shift;

    my $address = $info->{'address'};
    return unless($address);
    return unless($address =~ /^$RE{'URI'}/);
    return(1);
}

sub from {};

sub convert {
    my $class = shift;
    my $info = shift;
    my $iodef = shift;

    my $address = lc($info->{'address'});
    my $md5 = $info->{'md5'};
    my $sha1 = $info->{'sha1'};

    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ext-value');
    $iodef->add('IncidentEventDataFlowSystemNodeAddressext-category','url');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);

    if($md5){
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','md5');
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$md5);
    }
    if($sha1){
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
        $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','sha1');
        $iodef->add('IncidentEventDataFlowSystemAdditionalData',$sha1);
    }

    if($info->{'malware_md5'} || $info->{'malware_sha1'}){
        require CIF::Archive::Storage::Plugin::Iodef::Malware;
        $iodef = CIF::Archive::Storage::Plugin::Iodef::Malware->convert({
            source  => $info->{'source'},
            md5     => $info->{'malware_md5'},
            sha1    => $info->{'malware_sha1'},
            impact  => $info->{'impact'},
            description => $info->{'description'},
            detecttime  => $info->{'detecttime'},
        },$iodef);
    }
    return($iodef);
}

1;
