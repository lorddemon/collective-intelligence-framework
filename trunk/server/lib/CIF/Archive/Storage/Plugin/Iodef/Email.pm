package CIF::Archive::Storage::Plugin::Iodef::Email;

use Regexp::Common qw/URI/;

sub prepare {
    my $class   = shift;
    my $info    = shift;

use Data::Dumper;
    my $address = $info->{'address'};
    return unless($address);
    return if($address =~ /^$RE{'URI'}/);
    return unless(isEmail($address));
    return(1);
}

sub convert {
    my $self = shift;
    my $info = shift;
    my $iodef = shift;
    
    my $address = $info->{'address'};
    return($iodef) unless($address);
    return($iodef) unless(isEmail($address));

    $iodef->add('IncidentEventDataFlowSystemNodeAddresscategory','e-mail');
    $iodef->add('IncidentEventDataFlowSystemNodeAddress',$address);
    return $iodef;
}

sub isEmail {
    my $e = shift;
    return unless($e);
    return unless(lc($e) =~ /[a-z0-9_.-]+\@[a-z0-9.-]+\.[a-z0-9.-]{2,5}/);
    return(1);
}
1;
