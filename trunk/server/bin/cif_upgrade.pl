#!/usr/bin/perl -w

use strict;

use lib '/opt/BETA2/lib';
use lib '/opt/cif/lib';

use Getopt::Std;
use threads;
use threads::shared;

my %opts;
getopts('df:b:t:hsm:M:S:',\%opts);

our $debug      = $opts{'d'};
my $file        = $opts{'f'} || '/tmp/.cif_upgrade_bookmark';
my $batch       = $opts{'b'} || 10000;
my $threads     = $opts{'t'} || 8;
my $start       = $opts{'m'};
my $end         = $opts{'M'};
my $set         = $opts{'S'} || 200000;
my $bail = 0;

$SIG{'INT'} = sub {
    print "\n\nCaught Interrupt (^C), Aborting\n";
    $bail++;
    if($bail > 1){
       exit(-1);
    }
};

my $ret;
$ret = threads->create('get_minmax')->join();
my ($min,$max);
$min = $ret->{'min'};
$max = $ret->{'max'};

$min = $start if(defined($start));
$max = $end if(defined($end));

my $sets = int($max / $set) + 1;
foreach(0 ... $sets){
    threads->create('runme',$min,$min+$set)->join();
    $min = ($min+$set)+1;
}

sub runme {
    my ($min,$max) = @_;
my @joinable;
my @list;
my $t;
my @threads;

do {
    $t = scalar(threads->list());
    while($t >= $threads){
        @joinable = threads->list(threads::joinable);
        if($#joinable > -1){
            foreach(@joinable){
                $_->join();
                $t--;
            }
        } else {
            sleep(1);
            next();
        }
    }
    if($min + $batch > $max){
        $batch = ($max - $min);
    }
    my $done = (($min+$batch) / $max) * 100;
    $done = sprintf("%.3f",$done);

    warn 'processing: '.$min.' - '.($min+$batch).' -- '.$done.'% completed, '.$min.' out of '.$max if($debug);
    push(@threads,threads->create(\&process,$min,($min+$batch)));
    $min += $batch+1;
} while($min <= $max && !$bail);

while(threads->list()){
    @joinable = threads->list(threads::joinable);
    if($#joinable > -1){
        foreach(@joinable){
            $_->join();
        }
    } else {
        warn 'waiting to exit...' unless($bail);
        sleep(1);
        $bail = 1;
    }
}
}

sub process {
    my ($min,$max) = @_;
    my $recs = threads->create('get_recs',$min,$max)->join();
    require XML::IODEF;
    require CIF::Client::Plugin::Iodef;
    require XML::Malware;
    require CIF::Archive;
    use Regexp::Common qw/net/;
    my $m = XML::Malware->new();
    my $iodef = XML::IODEF->new();
    my ($msg,$ref,$tree);
    foreach my $rec (keys %$recs){
        $msg = $recs->{$rec}->{'message'};
        $tree = $iodef->in($msg)->to_tree();
        $ref = CIF::Client::Plugin::Iodef->hash_simple($tree);
        $ref = @{$ref}[0];

        # check to see if there was a malwre record attached
        if(my $r = $tree->{'Incident'}->{'EventData'}->{'Record'}->{'RecordData'}->{'RecordItem'}){
            if(ref($r) eq 'HASH' && $r->{'meaning'} eq 'malware sample'){
                $r = $m->in($r->{'content'});
                $ref->{'malware_md5'} = $r->{'id'};
            }
        }

        use Data::Dumper;
        my $impact = $ref->{'impact'}; 
        my $description = $ref->{'description'};
        my $addr = $ref->{'address'};
        if($addr && $addr =~ /^$RE{'net'}{'IPv4'}/){
            if($impact =~ / ([a-z0-9\.-]+\.[a-z]{2,5})$/){
                $ref->{'address'} = $1;
                $description =~ s/ $1//;
                $ref->{'rdata'} = $addr;
                $impact =~ s/infrastructure/domain/;
                $description =~ s/infrastructure/domain/;
                $description = 'unknown' if($impact eq $description);
            }
        }
        $impact =~ s/ [a-z0-9\.-]+\.[a-z]{2,5}$//;

        if($addr && $addr !~ /^http/){
            $description =~ s/$addr//;
            $description =~ s/\s$//;

            $impact =~ s/$addr//;
            $impact =~ s/\s$//;
        }


        unless($description eq $impact){
            $description =~ s/$impact//;
            $description =~ s/^\s//;
        }
        for(lc($impact)){
            if(/^mal(\S+).* url/){    
                $impact = 'malware url';
                last;
            }
            if(/^phish(\S+).* url/){
                $impact = 'phishing url';
                last;
            }
        }
        for(lc($description)){
            if(/zeus/){
                $impact =~ s/malware/botnet/;
                $description =~ s/malware/botnet/;
                last;
            }

        }

        if($impact =~ /url/){
            if($ref->{'address'} && $ref->{'address'} !~ /^http/){
                $ref->{'address'} = 'http://'.$ref->{'address'};
            }
        }

        if($impact =~ /^malware binary$/){
            $impact = 'malware';
        }

        if($ref->{'confidence'}){
            $ref->{'confidence'} = ($ref->{'confidence'} * 10 / 2);
        } else {
            $ref->{'confidence'} = 0;
        }
        $ref->{'impact'} = $impact;
        $ref->{'description'} = $description;
        if($ref->{'restriction'} && $ref->{'restriction'} eq 'public'){
            $ref->{'restriction'} = 'need-to-know';
        }

        my ($err,$id) = CIF::Archive->insert($ref);
        my $a = $ref->{'address'} || $ref->{'malware_md5'};
        #print $id->uuid().' -- '.$impact.' -- '.$description.' -- '.$a;
        #print "\n";
    }
}

sub get_minmax {
    my $p = 'CIF::Message::Structured';
    eval "require $p";
    
    my $min = $p->minimum_value_of('id');
    my $max = $p->maximum_value_of('id');

    return({
        min => $min,
        max => $max,
    });
}

sub get_recs {
    my $min = shift;
    my $max = shift;

    require CIF::Message::Structured;
    CIF::Message::Structured->set_sql('zzz' => qq{
        SELECT *
        FROM __TABLE__
        WHERE id >= $min AND id <= $max
        ORDER BY id ASC
    });
    my $sth = CIF::Message::Structured->sql_zzz();
    $sth->execute();
    my $hashref = $sth->fetchall_hashref('id');
    return($hashref);
}

