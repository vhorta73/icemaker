package Icemaker::Internal::DB::Schema::Result::DailyProduction;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('daily_production');
__PACKAGE__->add_columns(qw/id order_id machine_id recipe_id quantity_produced time_started time_finished status operator_id user_id creation_date last_updated_date/);
__PACKAGE__->set_primary_key('id');

1;
