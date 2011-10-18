package RT::Action::CIFMinimal_ProcessReport;

use strict;
use warnings;

use base 'RT::Action::Generic';
use RT::CIFMinimal;
use Regexp::Common qw(net);
use Regexp::Common::net::CIDR;

sub Prepare { return(1); }
my %rmap = RT->Config->Get('CIFMinimal_RestrictionMapping');

sub Commit {
    my $self = shift;

    my $tkt = $self->TicketObj();

    $tkt->SetOwner($tkt->CreatorObj->Id());
    my $addr = $tkt->FirstCustomFieldValue('Address');
    my $hash = $tkt->FirstCustomFieldValue('Hash');
    unless($addr || $hash){
        $tkt->SetStatus('rejected');
        return(undef);
    }

    my $cf = RT::CustomField->new($self->CurrentUser());
    
    if($addr){
        if($addr =~ /^$RE{'net'}{'IPv4'}$/){
            my $autoreject = RT->Config->Get('CIFMinimal_RejectPrivateAddress') || 1;
            if($autoreject && RT::CIFMinimal::IsPrivateAddress($addr)){
                $self->TicketObj->SetStatus('rejected');
                return(undef);
            }
            my $network_info = RT::CIFMinimal::network_info($addr);
            if($network_info){
                if($network_info->{'description'}) { $network_info->{'asn'} = $network_info->{'asn'}.' '.$network_info->{'description'}; }
                my $msg = $network_info->{'asn'}.' | '.$network_info->{'cidr'}.' | '.$network_info->{'cc'}.' | '.$network_info->{'rir'}.' | '.$network_info->{'modified'};
                $tkt->Comment(Content => $msg);
            }
        }
    }

    $self->TicketObj->SetStatus('open');
}

1;
