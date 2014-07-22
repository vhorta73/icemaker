package Icemaker::Internal::DB::Schema::Result::UserAccess;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('useer_access');
__PACKAGE__->add_columns(qw/user_id label authorized level creation_date last_updated_date/);
__PACKAGE__->set_primary_key('user_id');

1;
