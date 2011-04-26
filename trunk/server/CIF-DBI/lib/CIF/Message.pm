package CIF::Message;
use base 'CIF::Archive';

use strict;
use warnings;

use OSSP::uuid;

__PACKAGE__->table('message');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid format description message restriction created source/);
__PACKAGE__->columns(Essential => qw/id uuid created/);
__PACKAGE__->sequence('message_id_seq');

sub isUUID {
    my $arg = shift;
    return undef unless($arg);
    return undef unless($arg =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/);
    return(1);
}

sub normalize_timestamp {
    my $dt = shift;
    return $dt if($dt =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/);
    if($dt && ref($dt) ne 'DateTime'){
        if($dt =~ /^\d+$/){
            if($dt =~ /^\d{8}$/){
                $dt.= 'T00:00:00Z';
                $dt = eval { DateTime::Format::DateParse->parse_datetime($dt) };
                unless($dt){
                    $dt = DateTime->from_epoch(epoch => time());
                }
            } else {
                $dt = DateTime->from_epoch(epoch => $dt);
            }
        } elsif($dt =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(\S+)?$/) {
            my ($year,$month,$day,$hour,$min,$sec,$tz) = ($1,$2,$3,$4,$5,$6,$7);
            $dt = DateTime::Format::DateParse->parse_datetime($year.'-'.$month.'-'.$day.' '.$hour.':'.$min.':'.$sec,$tz);
        } else {
            $dt =~ s/_/ /g;
            $dt = DateTime::Format::DateParse->parse_datetime($dt);
            return undef unless($dt);
        }
    }
    $dt = $dt->ymd().'T'.$dt->hms().'Z';
    return $dt;
}

sub insert {
    my $self = shift;
    my $info = shift;

    if($info->{'detecttime'}){
        $info->{'detecttime'} = normalize_timestamp($info->{'detecttime'});
    }

    my $source  = $info->{'source'};
    $source = genSourceUUID($source) unless(isUUID($source));
    $info->{'source'} = $source;

    require CIF::Archive::Json;
    my $bucket = 'CIF::Archive::Json';
    foreach($self->plugins()){
        $bucket = $_ if($_->can($info));
    }

    my $msg = $bucket->to($info);

    $info->{'uuid'} = genMessageUUID($source,$msg);
    $info->{'message'} = $msg;

    my $id = eval { 
        $self->SUPER::insert({
            uuid        => $info->{'uuid'},
            format      => $info->{'format'},
            description => $info->{'description'},
            message     => $info->{'message'},
            restriction => $info->{'restriction'},
            source      => $info->{'source'},
        })
    };
    if($@){
        die $@ unless($@ =~ /duplicate key value violates unique constraint/);
        $id = CIF::Message->retrieve(uuid => $info->{'uuid'});
    }
    return $id;
}

sub genMessageUUID {
    my ($source,$msg) = @_;
    return undef unless($msg && $source);

    my $uuid = new OSSP::uuid();
    my $uuid_ns = new OSSP::uuid();
    $uuid_ns->load("UUID_NIL");
    $uuid->make("v5", $uuid_ns, $source.$msg);
    undef $uuid_ns;
    my $str = $uuid->export("str");
    undef $uuid;
    return($str);
}

sub genUUID {
    my $uuid    = OSSP::uuid->new();

    $uuid->make('v4');
    my $str = $uuid->export('str');
    undef $uuid;
    return($str);
}

sub genSourceUUID {
    my $source = shift;
    my $uuid = OSSP::uuid->new();
    my $uuid_ns = OSSP::uuid->new();
    $uuid_ns->load('ns::URL');
    $uuid->make("v3",$uuid_ns,$source);
    my $str = $uuid->export('str');
    undef $uuid;
    return($str);
}

1;
__END__
