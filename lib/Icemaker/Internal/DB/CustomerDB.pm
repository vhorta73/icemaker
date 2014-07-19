package Icemaker::Internal::DB::CustomerDB;

use Poet qw($conf);
use Moose;

use constant METHODS => (qw/id status name phone email creation_date last_updated_date/);

extends 'Icemaker::Internal::DB::BaseDB';

# Customer table structure
has 'id', is => 'rw', isa => 'Int';
has 'status', is => 'rw', isa => 'Str';
has 'name', is => 'rw', isa => 'Str';
has 'phone', is => 'rw', isa => 'Str';
has 'email', is => 'rw', isa => 'Str';
has 'creation_date', is => 'rw', isa => 'Str';
has 'last_updated_date', is => 'rw', isa => 'Str';

sub new {
    my $class = shift;
    my $id    = shift;
    my $self  = {};
    bless $self, $class;

    $self->_table('customer');
    $self->_primary_keys(['id']);
    $self->_db($conf->get('db.customer_db'));

    # Load data to object if found
    if ( defined $id ) {
        $self->_load($id);
        if ( my $data = $self->_data ) {
            foreach my $k ( keys %$data ) {
                next if not defined $data->{$k};
                $self->$k($data->{$k});
            }
        }
    }
    return $self;
}

# Object data in a hash format
sub hash {
    my $self = shift;
    my %data = map { $_ => $self->$_ } METHODS;
    return \%data;
}

1;
