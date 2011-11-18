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

package RT::IR::Federation;

our $VERSION = '0.01_2';

use warnings;
use strict;

use RT::Util 'safe_run_child';

sub PurgeKey{
        my $fingerprint = shift;
        return(loc('Must provide key-fingerprint!')) unless($fingerprint);

	$RT::Logger->debug('Purging fingerprint: '.$fingerprint);
    my $gnupg = new GnuPG::Interface;
    my %opt = RT->Config->Get('GnuPGOptions');

	require RT::Crypt::GnuPG;
    $gnupg->options->hash_init(
        RT::Crypt::GnuPG::_PrepareGnuPGOptions( %opt ),
        meta_interactive => 1,
    );

    my ($handles, $handle_list) = RT::Crypt::GnuPG::_make_gpg_handles();
    my %handle = %$handle_list;

    eval {
        local $SIG{'CHLD'} = 'DEFAULT';
        local @ENV{'LANG', 'LC_ALL'} = ('C', 'C');
        my $pid = safe_run_child { $gnupg->wrap_call(
            handles => $handles,
                commands        => [qw(--delete-secret-and-public-key --batch)],
                command_args    => [$fingerprint],
        ) };
        waitpid $pid, 0;
    };
    my $err = $@;
    close $handle{'stdout'};

    my %res;
    $res{'exit_code'} = $?;
    foreach ( qw(stderr logger status) ) {
        $res{$_} = do { local $/; readline $handle{$_} };
        delete $res{$_} unless $res{$_} && $res{$_} =~ /\S/s;
        close $handle{$_};
    }
    $RT::Logger->debug( $res{'status'} ) if $res{'status'};
    $RT::Logger->warning( $res{'stderr'} ) if $res{'stderr'};
    $RT::Logger->error( $res{'logger'} ) if $res{'logger'} && $?;
    if ( $err || $res{'exit_code'} ) {
        $res{'message'} = $err? $err : "gpg exitted with error code ". ($res{'exit_code'} >> 8);
    }

        return(%res);
}

eval "require RT::IR::Federation_Vendor";
die $@ if ($@ && $@ !~ qr{^Can't locate RT/IR/Federation_Vendor.pm});
eval "require RT::IR::Federation_Local";
die $@ if ($@ && $@ !~ qr{^Can't locate RT/IR/Federation_Local.pm});

1;
