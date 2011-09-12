package RT::Action::CIFMinimal_ProcessReport;

use strict;
use warnings;

use base 'RT::Action::Generic';
use RT::CIFMinimal;
use Regexp::Common qw(net);
use Regexp::Common::net::CIDR;

sub Prepare { return(1); }
my %rmap = RT->Config->Get('RestrictionMapping');

sub Commit {
    my $self = shift;

    my $tkt = $self->TicketObj();
    my $addr = $tkt->FirstCustomFieldValue('Address');
    my $hash = $tkt->FirstCustomFieldValue('Hash');
    unless($addr || $hash){
        $tkt->SetStatus('rejected');
        return(undef);
    }

    my $restriction = $tkt->FirstCustomFieldValue('Restriction') || 'need-to-know';
    if(my %rmap = RT->Config->Get('RestrictionMapping')){
        $restriction = $rmap{lc($restriction)};
    }
    my $cf = RT::CustomField->new($self->CurrentUser());
    $cf->Load('Restriction');
    $tkt->AddCustomFieldValue(Field => $cf, Value => $restriction);
    
    my $classification = $tkt->FirstCustomFieldValue('Assessment Impact');
    my $subject = $tkt->Subject();
    if($subject !~ $classification){
        $subject = $classification.' '.$subject;
        $self->TicketObj->SetSubject($subject);
    }
 
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
                $cf->Load('ASN');
                $tkt->AddCustomFieldValue(Field => $cf, Value => $network_info->{'asn'});
                $cf->Load('CIDR');
                $tkt->AddCustomFieldValue(Field => $cf, Value => $network_info->{'cidr'});

                my $msg = $network_info->{'asn'}.' | '.$network_info->{'cidr'}.' | '.$network_info->{'cc'}.' | '.$network_info->{'rir'}.' | '.$network_info->{'modified'};
                $tkt->Comment(Content => $msg);
            }
        }

        $cf->Load('Address Category');
        $tkt->AddCustomFieldValue(Field => $cf, Value => $addr_cat);
    }

    $self->TicketObj->SetStatus('open');
}

1;
