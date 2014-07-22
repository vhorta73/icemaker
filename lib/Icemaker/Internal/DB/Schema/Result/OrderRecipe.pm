package Icemaker::Internal::DB::Schema::Result::OrderRecipe;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('order_recipe');
__PACKAGE__->add_columns(qw/id order_id recipe_id status creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');

1;
