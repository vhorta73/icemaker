package Icemaker::Internal::DB::Schema::Result::Supplier;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('supplier');
__PACKAGE__->add_columns(qw/id status name phone email creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');

1;
