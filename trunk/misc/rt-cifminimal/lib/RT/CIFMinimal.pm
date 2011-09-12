# COPYRIGHT:
# 
# Copyright 2009 REN-ISAC and The Trustees of Indiana University
# 
# LICENSE:
# 
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org.
# 
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.html.
# 
# 
# CONTRIBUTION SUBMISSION POLICY:
# 
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to Best Practical Solutions, LLC.)
# 
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# Request Tracker, to Best Practical Solutions, LLC, you confirm that
# you are the copyright holder for those contributions and you grant
# Best Practical Solutions,  LLC a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.

package RT::CIFMinimal;

our $VERSION = '0.01_01';

use warnings;
use strict;

use Net::Abuse::Utils qw(:all);
use Net::CIDR;

sub network_info {
    my $addr = shift;

    my ($as,$network,$ccode,$rir,$date) = get_asn_info($addr);
    my $as_desc = '';
    if($as){
        $as_desc = get_as_description($as);
    }
    return({
        asn => $as,
        cidr    => $network,
        cc  => $ccode,
        rir => $rir,
        modified => $date,
        description => $as_desc,
    }) if($as);
    return(0);
}

my @list = (
    "0.0.0.0/8",
    "10.0.0.0/8",
    "127.0.0.0/8",
    "192.168.0.0/16",
    "169.254.0.0/16",
    "192.0.2.0/24",
    "224.0.0.0/4",
    "240.0.0.0/5",
    "248.0.0.0/5"
);

sub IsPrivateAddress {
    my $addr = shift;
    my $found =  Net::CIDR::cidrlookup($addr,@list);
    return($found);
}
{
my %cache;
sub GetCustomField {
    my $field = shift or return;
    return $cache{ $field } if exists $cache{ $field };

    my $cf = RT::CustomField->new( $RT::SystemUser );
    $cf->Load( $field );
    return $cache{ $field } = $cf;
}
}

use Hook::LexWrap;
use Regexp::Common;
use Regexp::Common::net::CIDR;

# on OCFV create format storage
require RT::ObjectCustomFieldValue;
wrap 'RT::ObjectCustomFieldValue::Create',
    pre => sub {
        my %args = @_[1..@_-2];
        my $cf = GetCustomField( 'Address' );
        unless ( $cf && $cf->id ) {
            $RT::Logger->crit("Couldn't load IP CF");
            return;
        }

        return unless $cf->id == $args{'CustomField'};

        for ( my $i = 1; $i < @_; $i += 2 ) {
            next unless $_[$i] && $_[$i] eq 'Content';

            my $arg = $_[++$i];
            next if ($arg =~ /^\s*$RE{net}{CIDR}{IPv4}{-keep}\s*$/go );
            my ($sIP, $eIP) = RT::IR::ParseIPRange( $arg );
            unless ( $sIP && $eIP ) {
                #$_[-1] = 0;
                return;
            }
            $_[$i] = $sIP;

            my $flag = 0;
            for ( my $j = 1; $j < @_; $j += 2 ) {
                next unless $_[$j] && $_[$j] eq 'LargeContent';
                $flag = $_[++$j] = $eIP;
                last;
            }
            splice @_, -1, 0, LargeContent => $eIP unless $flag;
            return;
        }
    };

eval "require RT::CIFMinimal_Vendor";
die $@ if ($@ && $@ !~ qr{^Can't locate RT/CIFMinimal_Vendor.pm});
eval "require RT::CIFMinimal_Local";
die $@ if ($@ && $@ !~ qr{^Can't locate RT/CIFMinimal_Local.pm});

package RT::User;
use Hook::LexWrap;

{
my $obj;
wrap 'RT::User::Create',
    pre => sub {
        my $user = $obj = $_[0];
        my %args = (@_[1..(@_-2)]);
        return if($args{'EmailAddress'});
        unless($args{'EmailAddress'}){ $args{'EmailAddress'} = $args{'Name'}; }
        my @res = $user->Create(%args);
        $_[-1] = \@res;
    },
    post => sub {
        return unless $_[-1];
        my $val = ref $_[-1]? \$_[-1][0]: \$_[-1];
        return unless($val =~ /\d+/);

        require RT::Group;
        my $default = RT->Config->Get('DefaultUserGroup') || return(undef);
        my $group = RT::Group->new($obj->CurrentUser());
        $group->LoadUserDefinedGroup($default);
        my ($ret,$errstr) = $group->_AddMember(InsideTransaction => 1, PrincipalId => $$val);
        unless($ret){
            $RT::Logger->crit("Couldn't add user to group: ".$group->Name());
            $RT::logger->crit($errstr);
            $RT::Handle->Rollback();
            return(0);
        }
    };
}
1;

