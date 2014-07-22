package Icemaker::Internal::DB::Schema::Result::Recipe;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('recipe');
__PACKAGE__->add_columns(qw/id name pasteurised duration final_size notes status creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');

1;
