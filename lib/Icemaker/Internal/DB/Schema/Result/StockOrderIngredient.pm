package Icemaker::Internal::DB::Schema::Result::StockOrderIngredient;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('stock_order_ingredient');
__PACKAGE__->add_columns(qw/id stock_order_id ingredient_id ordered_quantity received_quantity status user_id date_requested date_estimated date_closed creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');

1;
