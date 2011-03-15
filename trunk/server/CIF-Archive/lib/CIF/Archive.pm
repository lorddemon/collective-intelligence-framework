package CIF::Archive;
use base 'CIF::DBI';

use strict;
use warnings;

use Data::Dumper;
use Config::Simple;
use OSSP::uuid;

__PACKAGE__->set_table('archive');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid format description data restriction created source/);
__PACKAGE__->columns(Essential => qw/id uuid format description created/);
__PACKAGE__->sequence('archive_id_seq');

sub create_sql {
    return q{
        id bigserial primary key not null,
        uuid uuid not null,
        source uuid not null,
        format text,
        description text,
        restriction restriction default 'private',
        created timestamp with time zone default now(),
        data text not null,
        unique(uuid)
    };
}

sub plugins {
    my $class = shift;
    my $type = shift || return(undef);
    my $filter = shift;

    my @plugs;
    for(lc($type)){
        if(/^storage$/){
            require CIF::Archive::Storage;
            return CIF::Archive::Storage->plugins();
            last;
        }
        if(/^datatype$/){
            require CIF::Archive::DataType;
            my @p = CIF::Archive::DataType->plugins();
            # work-around for sub-classed objects
            @p = grep(!/SUPER$/,@p);
            @p = grep(!/Plugin::\S+::/,@p) if($filter);
            return(@p);
            last;
        }
    }
    return(@plugs);
}

sub set_table {
    my ($class,$table) = @_;
    $class->table($table);
    $class->_create_type();
    $class->_create_table();
}

sub _create_table {
    my $class = shift;
    my @vals = $class->sql__table_pragma->select_row();
    return unless($#vals < 0);
    $class->sql__create_me($class->create_sql())->execute();
}

sub _create_type {
    my $class = shift;
    my @vals = $class->sql__type_pragma->select_row('severity');
    if($#vals < 0){
        $class->sql__create_type_severity()->execute();
    }

    @vals = $class->sql__type_pragma->select_row('restriction');
    if($#vals < 0){
        $class->sql__create_type_restriction()->execute();
    }
}


sub check_params {
    my ($self,$tests,$info) = @_;
    
    foreach my $key (keys %$info){
        if(exists($tests->{$key})){
            my $test = $tests->{$key};
            next unless($info->{$key});
            unless($info->{$key} =~ m/$test/){
                return(undef,'invaild value for '.$key.': '.$info->{$key});
            }
        }
    }
    return(1);
}

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

    my $source  = $info->{'source'} || return('missing source',undef);
    $source = genSourceUUID($source) unless(isUUID($source));
    $info->{'source'} = $source;

    # defaults to json
    require CIF::Archive::Storage::Json;
    my $bucket = 'CIF::Archive::Storage::Json';
    if($info->{'storage'}){
        if($info->{'storage'} eq 'binary'){
            $bucket = 'CIF::Archive::Storage::Binary';
        }
    } else {
        foreach($self->plugins('storage')){
            $bucket = $_ if($_->prepare($info));
        }
    }

    my $msg = $bucket->to($info);
    unless($info->{'format'}){
        $info->{'format'} = $bucket->format();
    }

    $info->{'uuid'} = genMessageUUID($source,$msg);
    $info->{'data'} = $msg;

    my $id = eval {
        $self->SUPER::insert({
            uuid        => $info->{'uuid'},
            format      => $info->{'format'},
            description => $info->{'description'},
            data        => $info->{'data'},
            restriction => $info->{'restriction'} || 'private',
            source      => $info->{'source'} || 'localhost',
        })
    };
    if($@){
        die $@ unless($@ =~ /duplicate key value violates unique constraint/);
        $id = $self->retrieve(uuid => $info->{'uuid'});
    }
    
    $info->{'uuid'} = $id->uuid();
    foreach($self->plugins('datatype')){
        if($_->prepare($info)){
            $_->insert($info);
        }
    }   
    return $id;
}

sub lookup {
    my $class = shift;
    my $info = shift;

    foreach($class->plugins('datatype',1)){
        if(my $ret = $_->lookup($info->{'query'})){
            return(@$ret);
        }
    }
    return(undef);
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
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::DBI - Perl extension for interfacing with the CIF data-warehouse.

=head1 SYNOPSIS

  use CIF::DBI;
  blah blah blah

=head1 DESCRIPTION

=cut

