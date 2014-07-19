package Icemaker::Internal::DB::BaseDB;

use Moose;

has '_table', is => 'rw', isa => 'Str', required => 1;
has '_db', is => 'rw', isa => 'Str', required => 1;
has '_primary_keys', is => 'rw', isa => 'ArrayRef',  required => 1;
has '_data',  is => 'rw', isa => 'Any';

# Load all table data for a given id.
sub _load {
    my $self  = shift;
    my $id    = shift || die "Please supply an id";
    my $table = $self->_table;
    my $db    = $self->_db;

    $self->_data( 
        $::DBS->get_hash({
            db  => $db,
            sql => qq{ 
                SELECT * 
                FROM $table 
                WHERE id = ? 
            },
            bind_values => [ $id ],
        }) 
    );
}

# Save all data to table unless already exists.
sub save {
    my $self = shift;
}

# Update a field to the table on the give id.
sub update {
    my $self  = shift;
    my $label = shift || die "Please supply column name";
}

=pod to_json

Default to JSON conversion of the object _data

=cut
sub to_json {
    my $self = shift;
    my $data = shift || $self->_data;
    return $data ? $::JSON->encode($data) : undef;
}

1;
