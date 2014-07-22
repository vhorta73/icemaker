package Icemaker::Internal::DB::Schema::Result::Orders;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('orders');
__PACKAGE__->add_columns(qw/id customer_id status creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to( 'customer' => 'Icemaker::Internal::DB::Schema::Result::Customer', {'foreign.customer_id' => 'self.id' } );

1;
