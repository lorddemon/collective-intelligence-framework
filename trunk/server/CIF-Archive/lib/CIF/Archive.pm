package CIF::Archive;
use base 'CIF::DBI';

require 5.008;
use strict;
use warnings;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use Data::Dumper;
use Config::Simple;
use DateTime::Format::DateParse;
use OSSP::uuid;

__PACKAGE__->table('archive');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid format description data restriction created source/);
__PACKAGE__->columns(Essential => qw/id uuid format description source restriction data created/);
__PACKAGE__->sequence('archive_id_seq');

sub plugins {
    my $class = shift;
    my $type = shift || return(undef);

    my @plugs;
    for(lc($type)){
        if(/^storage$/){
            require CIF::Archive::Storage;
            return CIF::Archive::Storage->plugins();
            last;
        }
        if(/^datatype$/){
            require CIF::Archive::DataType;
            return CIF::Archive::DataType->plugins();
            last;
        }
    }
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

## TODO -- this could get really slow
## might be best to not use the XML storage and just use straight up JSON

__PACKAGE__->add_trigger(select => \&data);

sub data {
    my $class = shift;
    my $data = $class->{'data'};
    my $format = $class->{'format'};
    return $data unless($format && $format eq 'iodef');

    use CIF::Archive::Storage::Plugin::Iodef;
    $data = CIF::Archive::Storage::Plugin::Iodef->from($data);
    $data->{'uuid'} = $class->uuid();
    return($data);
    
}

sub insert {
    my $self = shift;
    my $info = shift;

    my $source  = $info->{'source'} || 'localhost';
    $source = genSourceUUID($source) unless(isUUID($source));
    $info->{'source'} = $source;

    # need to run through this first; make sure it's worth doing the insert
    ## TODO -- make this support multiple plugins, we may want to index this 7 ways to sunday.
    my @dt_plugs;
    foreach($self->plugins('datatype')){
        my ($ret,$err) = $_->prepare($info);
        # next unless we have something to work with
        # 0 - means there's something wrong with the value (whitelisted, private address space, etc)
        next unless(defined($ret));
        # if there's an error; return the error (eg: whitelisted...)
        return(undef,$err) if($ret == 0);
        # we do the CIF::Arvhive->insert() first, then insert to this plugin at the end
        push(@dt_plugs,$_);
    }

    # defaults to json
    require CIF::Archive::Storage::Json;
    my $bucket = 'CIF::Archive::Storage::Json';
    if($info->{'storage'} && $info->{'storage'} eq 'binary'){
        $bucket = 'CIF::Archive::Storage::Binary';
    } else {
        foreach($self->plugins('storage')){
            $bucket = $_ if($_->prepare($info));
        }
    }
    delete($info->{'storage'});

    my $msg = $bucket->convert($info);
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
            source      => $info->{'source'} || 'unknown',
        })
    };
    if($@){
        return($@,undef) unless($@ =~ /duplicate key value violates unique constraint/);
        $id = $self->retrieve(uuid => $info->{'uuid'});
    }
    $info->{'uuid'} = $id->uuid();
    delete($info->{'format'});
    # now do the plugin insert
    foreach my $p (@dt_plugs){
        my ($did,$err) = $p->insert($info);
        if($err){
            $id->delete();
            return($err,undef);
        }
    }
    return(undef,$id);
}

sub lookup {
    my $class = shift;
    my $info = shift;
    $info->{'limit'} = 10000 unless($info->{'limit'});

    foreach($class->plugins('datatype')){
        if(my $ret = $_->lookup($info)){
            unless($info->{'nolog'}){
                my $source = genSourceUUID($info->{'source'} || 'unknown');
                my $dt = DateTime->from_epoch(epoch => time());
                $dt = $dt->ymd().'T'.$dt->hour().':00:00Z';
                my $q = lc($info->{'query'});
                my ($md5,$sha1,$addr);
                for($q){
                    if(/^[a-f0-9]{32}$/){
                        $md5 = $q;
                        last;
                    }
                    if(/^[a-f0-9]{40}$/){
                        $sha1 = $q;
                        last;
                    }
                    $addr = $q;
                }

                my ($err,$id) = CIF::Archive->insert({
                    address => $addr || '',
                    source  => $source,
                    impact  => 'search',
                    description => 'search '.$info->{'query'},
                    detecttime  => $dt,
                    hash_md5    => $md5 || '',
                    hash_sha1   => $sha1 || '',
                });
                warn ($err) if($err);
            }
            return($ret);
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
=head1 NAME

CIF::Archive - Perl extension for interfacing with the CIF Archive.

=head1 SYNOPSIS

  use CIF::Archive

  my $a = CIF::Archive->new();
  my $id = $a->insert({
    address     => '1.1.1.1',
    portlist    => '22',
    impact      => 'scanner',
    severity    => 'medium',
    description => 'ssh scanner',
  });

  my @recs = CIF::Archive->search(descripion => 'ssh scanner');

  # ->lookup() is an API into the plugins, searches the index tables automatically
  # the plugin stack figures out which plugin understands '1.1.1.1' (eg: CIF::Archive::DataType::Plugin::Infrastructure::prepare)

  my $qid = $a->lookup({
    query   => '1.1.1.1',
  });

  my $qid = $a->lookup({
    query   => 'scanner',
  });

  my $id = $a->insert({
    address     => 'example.com',
    impact      => 'malware domain',
    description => 'mebroot',
  });

  CIF::Archive->connection('DBI:Pg:database=cif2;host=localhost','postgres','',{ AutoCommit => 1} );

=head1 DESCRIPTION

This module was created to be a generic storage "archive" for the Collective Intelligence Framework. It's simple and is to be exteded both by CIF::Archive::DataType and CIF::Archive::Storage for both custom indicies and storage formats. It's accompanied by CIF::WebAPI as an extensible framework for creating REST based (Apache2::REST) services around these extensions.

=head1 SEE ALSO

 http://code.google.com/p/collective-intelligence-framework/
 CIF::WebAPI
 CIF::Archive::DataType::Plugin::Feed
 CIF::Archive::Storage::Plugin::Iodef
 CIF::FeedParser

=head1 AUTHOR

Wes Young, E<lt>wes@barely3am.comE<gt>

=head1 COPYRIGHT AND LICENSE

 Copyright (C) 2011 by Wes Young (claimid.com/wesyoung)
 Copyright (C) 2011 by the Trustee's of Indiana University (www.iu.edu)
 Copyright (C) 2011 by the REN-ISAC (www.ren-isac.net)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

