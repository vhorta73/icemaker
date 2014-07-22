package Icemaker::Internal::DB::Schema::Result::Customer;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('customer');
__PACKAGE__->add_columns(qw/id status name phone email creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many( 'orders' => 'Icemaker::Internal::DB::Schema::Result::Orders', 'customer_id' );

1;
