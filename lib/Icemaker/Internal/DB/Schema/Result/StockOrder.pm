package Icemaker::Internal::DB::Schema::Result::StockOrder;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('stock_order');
__PACKAGE__->add_columns(qw/id supplier_id status user_id creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');

1;
