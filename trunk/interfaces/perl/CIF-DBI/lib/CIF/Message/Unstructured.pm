package CIF::Message::Unstructured;
use base 'CIF::DBI';

use strict;
use warnings;

__PACKAGE__->table('messages_unstructured');
__PACKAGE__->columns(Primary => 'id');
__PACKAGE__->columns(All => qw/id uuid  message tsv created/);
__PACKAGE__->columns(Essential => qw/id uuid message created/);
__PACKAGE__->sequence('messages_unstructured_id_seq');
__PACKAGE__->has_a(uuid => 'CIF::Message');
