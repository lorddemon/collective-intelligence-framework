package CIF::Message;
use base 'CIF::DBI';

use strict;
use warnings;

use OSSP::uuid;

__PACKAGE__->table('message');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid type format source confidence severity description impact restriction detecttime created/);
__PACKAGE__->columns(Essential => qw/id uuid type created/);
__PACKAGE__->sequence('message_id_seq');
__PACKAGE__->might_have(unstructured => 'CIF::Message::Unstructured');
__PACKAGE__->might_have(structured => 'CIF::Message::Structured');

sub isUUID {
    my $arg = shift;
    return undef unless($arg);
    return undef unless($arg =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/);
    return(1);
}

sub insert {
    my $self = shift;
    my $info = {%{+shift}};

    my $id = eval { $self->SUPER::insert($info)};
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

__PACKAGE__->set_sql('by_impact' => qq{
    SELECT * 
    FROM __TABLE__
    WHERE lower(impact) LIKE ?
    ORDER BY detecttime DESC, created DESC, id DESC
    LIMIT ?
});


1;
__END__
