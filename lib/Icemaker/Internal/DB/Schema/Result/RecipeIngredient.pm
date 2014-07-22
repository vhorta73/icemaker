package Icemaker::Internal::DB::Schema::Result::RecipeIngredient;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('recipe_ingredient');
__PACKAGE__->add_columns(qw/recipe_id ingredient_id quantity units/);
__PACKAGE__->set_primary_key('recipe_id','ingredient_id');

1;
