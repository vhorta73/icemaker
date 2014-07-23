package Icemaker::Internal::DB::Schema::Result::Operator;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('operator');
__PACKAGE__->add_columns(qw/id first_name last_name status creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');

1;
