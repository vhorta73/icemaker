package Icemaker::Internal::DB::Schema::Result::Package;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('package');
__PACKAGE__->add_columns(qw/id name size units in_stock status creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');

1;
