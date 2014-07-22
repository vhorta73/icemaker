package Icemaker::Internal::DB::Schema::Result::Machine;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('machine');
__PACKAGE__->add_columns(qw/id name status creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');

1;
