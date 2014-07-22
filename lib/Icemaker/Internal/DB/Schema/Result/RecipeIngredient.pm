package Icemaker::Internal::DB::Schema::Result::RecipeIngredient;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('recipe_ingredient');
__PACKAGE__->add_columns(qw/order_recipe_id package_id quantity creation_date last_updated_date/);
__PACKAGE__->set_primary_key('order_recipe_id','package_id');

1;
