package Icemaker::Internal::DB::Schema::Result::User;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('user');
__PACKAGE__->add_columns(qw/id name username password status creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');

1;
