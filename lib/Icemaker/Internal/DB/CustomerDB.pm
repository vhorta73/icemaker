package Icemaker::Internal::DB::CustomerDB;

use Poet qw($conf);
use Moose;

use constant METHODS => (qw/id status name phone email creation_date last_updated_date/);

extends 'Icemaker::Internal::DB::BaseDB';

# Customer table structure
has 'id',                is => 'rw', isa => 'Int', trigger => sub { shift->_load_by_id };
has 'status',            is => 'rw', isa => 'Str';
has 'name',              is => 'rw', isa => 'Str';
has 'phone',             is => 'rw', isa => 'Str';
has 'email',             is => 'rw', isa => 'Str';
has 'creation_date',     is => 'rw', isa => 'Str';
has 'last_updated_date', is => 'rw', isa => 'Str';

sub new {
    my $class = shift;
    my $id    = shift;
    my $self  = {};
    bless $self, $class;

    # Table to query for this calss
    $self->_table('customer');

    # Primary keys for this table
    $self->_primary_keys(['id']);

    # Auto increment column
    $self->_auto_increment('id');

    # Database to use from config
    $self->_db($conf->get('db.customer_db'));

    # Strict to force existing primary_keys when loading
    $self->_strict_queries(1);

    # Load data to object if found
    if ( defined $id ) {
        $self->_load({ id => $id });
    }
    return $self;
}

# Object data in a hash format
sub hash {
    my $self = shift;
    my $hash;
    foreach my $k ( METHODS ) {
        next if not defined $self->$k;
        $hash->{$k} = $self->$k;
    }
    return $hash;
}

sub _load_by_id {
    my $self = shift;
    $self->_load({ id => $self->id });
}

1;
