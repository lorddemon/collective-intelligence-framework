package CIF::Archive;
use base 'CIF::DBI';

require 5.008;
use strict;
use warnings;

use Data::Dumper;
use Config::Simple;
use CIF::Utils ':all';

require CIF::Archive::Storage;
require CIF::Archive::DataType;

__PACKAGE__->table('archive');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid source guid format description data restriction created/);
__PACKAGE__->columns(Essential => qw/id uuid format description source restriction data created/);
__PACKAGE__->sequence('archive_id_seq');

my @storage_plugs = CIF::Archive::Storage->plugins();
my @datatype_plugs = CIF::Archive::DataType->plugins();

sub plugins {
    my $class = shift;
    my $type = shift || return(undef);

    my @plugs;
    for(lc($type)){
        if(/^storage$/){
            return @storage_plugs;
            last;
        }
        if(/^datatype$/){
            return @datatype_plugs;
            last;
        }
    }
}

sub data_hash {
    my $class = shift;
    foreach my $p ($class->plugins('storage')){
        if(my $h = $p->data_hash($class->data(),$class->uuid())){
            return($h);
        }
    }
    my $hash = JSON::from_json($class->data());
    $hash->{'uuid'} = $class->uuid();
    return JSON::from_json($class->data());
}

sub data_hash_simple {
    my $class = shift;
    my $data = shift || $class->data();
    foreach my $p ($class->plugins('storage')){
        if(my $h = $p->data_hash_simple($data,$class->uuid())){
            return($h);
        }
    }
    return($class->data_hash());
}

sub insert {
    my $self = shift;
    my $info = shift;

    my $source  = $info->{'source'} || 'localhost';
    $source = genSourceUUID($source) unless(isUUID($source));
    $info->{'source'} = $source;

    my $guid = $info->{'guid'} || 'root';
    $guid = genSourceUUID($guid) unless(isUUID($guid));
    $info->{'guid'} = $guid;
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

    ## TODO -- test this
    ## http://archives.postgresql.org/pgsql-performance/2008-12/msg00225.php
    ## write out to a tmp table; them merge the non dups via query?
    my $r = $self->retrieve(uuid => $info->{'uuid'});

    my $id;
    if($r){
        $id = $r;
    } else {
        $id = eval {
            # this needs to be here
            # if we manipulate __DIE__ in the global space it creates
            # all sorts of problems for catching duplicate key violations
            $self->SUPER::insert({
                uuid        => $info->{'uuid'},
                format      => $info->{'format'},
                description => lc($info->{'description'}),
                data        => $info->{'data'},
                restriction => $info->{'restriction'} || 'private',
                source      => $info->{'source'} || 'unknown',
                guid        => $info->{'guid'},
                created     => $info->{'created'} || DateTime->from_epoch(epoch => time()),
            });
        };
        if($@){
            $self->dbi_rollback() unless($self->db_Main->{'AutoCommit'});
            return($@,undef);
        }
    }

    delete($info->{'format'});
    # now do the plugin insert
    foreach my $p (@dt_plugs){
        my ($did,$err) = eval {
            #local $SIG{__DIE__};
            ## TODO -- same here, see above, this is prolly too slow
            my $pid = $p->retrieve(uuid => $id->uuid());
            unless($pid){
                $pid = $p->insert($info);
            }
        };
        if($@){
            if($self->db_Main->{'AutoCommit'}){
                $id->delete();
            } else {
                $self->dbi_rollback();
            }
            return($@,undef);
        }
    }
    return(undef,$id);
}

#__PACKAGE__->set_sql(MakeNewObj => qq{ 
#    BEGIN
#        INSERT INTO __TABLE__ (%s) VALUES (%s)
#        RETURN
#    EXCEPTION WHEN unique_violation THEN
#         -- do nothing
#    END;
#});

__PACKAGE__->set_sql('lookup' => qq{
    SELECT __TABLE__.id,__TABLE__.uuid
    FROM __TABLE__
    LEFT JOIN apikeys_groups on __TABLE__.guid = apikeys_groups.guid
    WHERE __TABLE__.uuid = ?
    AND apikeys_groups.uuid = ?
});

__PACKAGE__->set_sql('lookup_guid' => qq{
    SELECT __TABLE__.id,__TABLE__.uuid
    FROM __TABLE__
    WHERE __TABLE__.uuid = ?
    AND __TABLE__.guid = ?
});


sub lookup {
    my $class = shift;
    my $info = shift;
    $info->{'limit'} = 10000 unless($info->{'limit'});

    my $ret;
    if(isUUID($info->{'query'})){
        ## TODO -- setup group perms
        my $key = $info->{'guid'} || $info->{'apikey'};
        my @recs;
        # we assume here they have the right to do this
        # acl's should be checked at the door
        if($info->{'guid'}){
            @recs = eval {
                CIF::Archive->search_lookup_guid($info->{'query'},$info->{'guid'});
            };
        } else {
            @recs = eval {
                CIF::Archive->search_lookup($info->{'query'},$info->{'apikey'});
            };
        }
        return($@,undef) if($@);
        $ret = $recs[0];
    } else {
        foreach my $p ($class->plugins('datatype')){
            $ret = eval { $p->lookup($info) };
            last if($ret);
            return($@,undef) if($@);
        }
    }

    unless($info->{'nolog'}){
        my $source = genSourceUUID($info->{'source'} || 'unknown');
        my $q = lc($info->{'query'});
        my ($uuid,$md5,$sha1,$addr);
        my $confidence  = 50;
        my $severity    = 'low';
        my $restriction = 'private';
        my $guid        = $info->{'guid'} || $info->{'default_guid'};
        my $detecttime;

        for($q){
            if(/^[a-f0-9]{32}$/){
                $md5 = $q;
                last;
            }
            if(/^[a-f0-9]{40}$/){
                $sha1 = $q;
                last;
            }
            if(isUUID($q)){
                $uuid = $q;
                last;
            }
            if(/ feed$/){
                $confidence     = $info->{'confidence'};
                $severity       = $info->{'severity'};
                $restriction    = $info->{'restriction'};
                $detecttime     = DateTime->from_epoch(epoch => time());
                last;
            }
            $addr = $q;
        }

        my ($err,$id) = CIF::Archive->insert({
            address     => $addr,
            source      => $source,
            impact      => 'search',
            description => 'search '.$info->{'query'},
            md5         => $md5,
            sha1        => $sha1,
            uuid        => $uuid,
            confidence  => $confidence,
            severity    => $severity,
            guid        => $guid,
            restriction => $restriction,
            detecttime  => $detecttime,
        });
    }
    return(undef,$ret);
}

sub create_partition {
    my $class = shift;
    my $date = shift;
    my $day = $date->ymd('_');
    my $start = $date->ymd.'T00:00:00Z';
    my $end = $date->ymd.'T23:59:59Z';

    __PACKAGE__->set_sql('create_partition' => qq{
        DROP TABLE IF EXISTS archive_$day;
        CREATE TABLE archive_$day (
            CHECK (created >= DATE '$start' AND created <= '$end')
        ) INHERITS(archive) TABLESPACE archive;
        set default_tablespace = 'index';
        ALTER TABLE archive_$day ADD PRIMARY KEY (id);
        ALTER TABLE archive_$day ADD UNIQUE(uuid);
    });
    return $class->sql_create_partition()->execute();
} 

sub prune {
    my $class = shift;
    my $date = shift || return;
    $class->db_Main->{'AutoCommit'} = 0;

    foreach (@datatype_plugs){
        warn 'pruning: '.$_ if($::debug);
        eval { $_->sql_prune->execute($date); };
        if($@){
            warn $@;
            $class->dbi_rollback();
            return(0);
        }
    }

    eval { $class->sql_prune->execute($date); };
    if($@){
        warn $@;
        $class->dbi_rollback();
        return(0);
    }
    $class->dbi_commit();
    return(1);
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

