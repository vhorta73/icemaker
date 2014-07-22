package Icemaker::Internal::DB::Schema::Result::Ingredient;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('ingredient');
__PACKAGE__->add_columns(qw/id name status in_stock creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');

1;
