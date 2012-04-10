package CIF::Archive::Storage::Plugin::Iodef::Url;

use Regexp::Common qw /URI/;
use URI::Escape;
use Digest::SHA1 qw/sha1_hex/;
use Digest::MD5 qw/md5_hex/;

sub prepare {
    my $class   = shift;
    my $info    = shift;

    my $address = $info->{'address'};
    return unless($address);
    $address = lc($address);
    my $safe = uri_escape($address,'\x00-\x1f\x7f-\xff');
    return unless(isUrl($info->{'address'}));
    $address = $safe;
    $info->{'address'} = $safe;
    $info->{'md5'} = md5_hex($safe) unless($info->{'md5'});
    $info->{'sha1'} = sha1_hex($safe) unless($info->{'sha1'});
    return(1);
}

sub isUrl {
    my $address = shift;
    return unless($address);
    return unless($address =~ /^$RE{'URI'}/ || $address =~ /^$RE{'URI'}{'HTTP'}{-scheme => 'https'}/);
    return(1);
}

sub convert {
    my $class = shift;
    my $info = shift;
    my $iodef = shift;

    my $address = lc($info->{'address'});

    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','ext-value');
    $iodef->add('IncidentEventDataFlowSystemNodeAddressext-category','url');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);

    $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
    $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','md5');
    $iodef->add('IncidentEventDataFlowSystemAdditionalData',$info->{'md5'});

    $iodef->add('IncidentEventDataFlowSystemAdditionalDatadtype','string');
    $iodef->add('IncidentEventDataFlowSystemAdditionalDatameaning','sha1');
    $iodef->add('IncidentEventDataFlowSystemAdditionalData',$info->{'sha1'});

    return($iodef);
}

1;
