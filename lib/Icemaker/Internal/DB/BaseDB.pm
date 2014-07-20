package Icemaker::Internal::DB::BaseDB;

use Moose;

has '_table', is => 'rw', isa => 'Str', required => 1;
has '_auto_increment', is => 'rw', isa => 'Str', default => 'id';
has '_db', is => 'rw', isa => 'Str', required => 1;
has '_primary_keys', is => 'rw', isa => 'ArrayRef',  required => 1;
has '_strict_queries', is => 'rw', isa => 'Bool', default => 0;

use constant READONLY => (qw/creation_date last_updated_date/);

=pod _validate_args

'expected' requires an array of keys
'validate' requires a hash

=cut
sub _validate_args {
    my $self = shift;
    my $args = shift || die "No args defined";
    die "No 'expected' args supplied" if not defined $args->{expected};
    die "No 'validate' args supplied" if not defined $args->{validate};

    foreach my $k ( @{$args->{expected}} ) {
        die "$k was expected and not found in args" if not defined $args->{validate}->{$k};
    }
}

# Load all table data for a given primary keys by default.
sub _load {
    my $self = shift;
    my $data = shift || die "Need some data to load";

    # Strict only allows queries with all primary keys given at least
    if ( !$self->_strict_queries ) {
        $self->_validate_args({ validate => $data, expected => $self->_primary_keys });
    }

    my $query = $self->_select_query($data); 
    my $hash  = $::DBS->get_hash($query);
    my %pk    = map { $_ => 1 } @{$self->_primary_keys};
    foreach my $k ( keys %{$hash} ) {
        next if defined $pk{$k};
        $self->$k($hash->{$k});
    }
}

# prepare select query
sub _select_query {
    my $self  = shift;
    my $data  = shift || die "No keys given to query";
    my $table = $self->_table;
    my $db    = $self->_db;
    my $bind;
    my $where;

    foreach my $k ( keys %$data ) {
        push @{$where}, " $k = ? ";
        push @{$bind}, $data->{$k};
    }

    if ( scalar @$where ) {
        $where = join('AND', @$where);
    }
    else {
        return undef;
    }

    my $query = {
        db  => $db,
        sql => qq{ SELECT * FROM $table WHERE $where },
        bind_values => $bind,
    };

    return $query;
}

# prepare insert query
sub _insert_query {
    my $self  = shift;
    my $data  = shift || die "No keys given to query";
    my $table = $self->_table;
    my $db    = $self->_db;
    my $bind;
    my $columns;
    my $values;

    my %pk = map { $_ => 1 } @{$self->_primary_keys};
    my %ro = map { $_ => 1 } READONLY;

    foreach my $k ( keys %$data ) {
        next if defined $pk{$k};
        next if defined $ro{$k};
        push @{$columns}, $k;
        push @{$values}, "?";
        push @{$bind}, $data->{$k};
    }

    if ( defined $columns and scalar @$columns ) {
        $columns = "(" . join(',', @$columns) . ")";
        $values  = "(" . join(',', @$values) . ")";
    }
    else {
        return undef;
    }

    my $query = {
        db  => $db,
        sql => qq{ INSERT INTO $table $columns VALUES $values },
        bind_values => $bind,
    };

    return $query;
}

# prepare update query
sub _update_query {
    my $self  = shift;
    my $data  = shift || die "No keys given to query";
    my $table = $self->_table;
    my $db    = $self->_db;
    my $bind;
    my $where_bind;
    my $set_columns;
    my $where;

    # An update is only authorized if all primary keys are given
    $self->_validate_args({ validate => $data, expected => $self->_primary_keys });

    my %pk = map { $_ => 1 } @{$self->_primary_keys};
    my %ro = map { $_ => 1 } READONLY;

    foreach my $k ( keys %$data ) {
        if ( defined $pk{$k} ) {
            push @{$where}, " $k = ? ";
            push @{$where_bind}, $data->{$k};
        } 
        else {
            # Do not set READONLY columns
            next if defined $ro{$k};
            push @{$set_columns}, " $k = ? ";
            push @{$bind}, $data->{$k};
        }
    }

    if ( defined $set_columns and scalar @$set_columns ) {
        $set_columns = " SET " . join(', ', @$set_columns);
        $where  = " WHERE " . join(' AND ', @$where);
    }
    else {
        return undef;
    }

    my $query = {
        db  => $db,
        sql => qq{ UPDATE $table $set_columns $where },
        bind_values => [ @$bind, @$where_bind ],
    };

    return $query;
}

=pod insert

Insert a new record with set data.

=cut
sub insert {
    my $self = shift;
    my $hash  = $self->hash;
    my $query = $self->_insert_query($hash);
    if ( defined $query ) {
        my $id = $::DBS->execute($query);
        my $auto_increment = $self->_auto_increment;
        # Reloads saved data to pick the new id up.
        $self->$auto_increment($id);
    }
}

=pod

Update PK DB pointed set record with set data. 

=cut
sub update {
    my $self  = shift;
    my $hash  = $self->hash;
    my $query = $self->_update_query($hash);
    $::DBS->execute($query) if defined $query;
}

=pod json

JSON data conversion for hash, the current updated data (possibly not DB updated yet).

=cut
sub json {
    my $self = shift;
    my $hash = shift || $self->hash;
    return $hash ? $::JSON->encode($hash) : undef;
}

1;
