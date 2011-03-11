package CIF::DBI;
use base Class::DBI;

use strict;
use warnings;
use Data::Dumper;
use Config::Simple;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

__PACKAGE__->connection('DBI:Pg:database=cif;host=localhost','postgres','',{ AutoCommit => 1} );
__PACKAGE__->set_sql(_create_me => 'CREATE TABLE __TABLE__ (%s)');
__PACKAGE__->set_sql(_create_me_index => 'CREATE TABLE __TABLE__ () INHERITS (%s)');
__PACKAGE__->set_sql(_table_pragma => 'select * from pg_stat_user_tables where relname = \'__TABLE__\'');
__PACKAGE__->set_sql(_type_pragma => "select typname from pg_type where typname = ?");
__PACKAGE__->set_sql(_create_type_severity => "create type severity as enum ('low','medium','high')");
__PACKAGE__->set_sql(_create_type_restriction => "create type restriction as enum ('public','need-to-know','private','default')");

sub set_table {
    my ($class,$table) = @_;
    $class->table($table);
    $class->_create_table();
    $class->_create_type();
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

__PACKAGE__->set_sql('feed' => qq{
    SELECT * FROM __TABLE__
    WHERE detecttime >= ?
    AND severity >= ?
    AND restriction <= ?
    AND NOT (lower(impact) LIKE 'search %' OR lower(impact) LIKE '% whitelist %')
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});

1;
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::DBI - Perl extension for interfacing with the CIF data-warehouse.

=head1 SYNOPSIS

  use CIF::DBI;
  blah blah blah

=head1 DESCRIPTION

=cut

