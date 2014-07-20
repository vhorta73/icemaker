package Icemaker::Internal::DB::RecipeDB;

use Poet qw($conf);
use Moose;

use constant METHODS => (qw/id name pasteurised duration final_size notes status creation_date last_updated_date/);

extends 'Icemaker::Internal::DB::BaseDB';

# Table structure
has 'id',                is => 'rw', isa => 'Int', trigger => sub { shift->_load_by_id };
has 'name',              is => 'rw', isa => 'Str';
has 'pasteurised',       is => 'rw', isa => 'Int';
has 'duration',          is => 'rw', isa => 'Str';
has 'final_size',        is => 'rw', isa => 'Str';
has 'notes',             is => 'rw', isa => 'Any';
has 'status',            is => 'rw', isa => 'Str';
has 'creation_date',     is => 'rw', isa => 'Str';
has 'last_updated_date', is => 'rw', isa => 'Str';

sub new {
    my $class = shift;
    my $id    = shift;
    my $self  = {};
    bless $self, $class;

    # Table to query for this calss
    $self->_table('recipe');

    # Primary keys for this table
    $self->_primary_keys(['id']);

    # Auto increment column
    $self->_auto_increment('id');

    # Database to use from config
    $self->_db($conf->get('db.recipe_db'));

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
