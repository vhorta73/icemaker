package Icemaker::Internal::Supplier;

use warnings;
use strict;

use Poet qw($conf $poet);

my $supplier_db = $conf->get('db.supplier_db');

sub new {
    my $self = shift;
    my $id = shift;
    my $class = {}; 
    bless ( $class, $self );
    $class->_load({ id => $id }) if defined $id;
    return $class;
}

sub _load {
    my $self = shift;
    my $args = shift;

    my $where = " 1 ";
    my $bind;
    foreach my $key ( qw/id name/ ) {
        if ( defined $args->{$key} ) {
            if ( defined $args->{strict} ) {
                $where .= " AND $key = ? ";
                push @$bind, $args->{$key};
            } else {
                $where .= " AND $key LIKE ? ";
                push @$bind, "%".$args->{$key}."%";
            }
        }
    }
 
    my $supplier = $::DBS->get_hasharray({
        db  => $supplier_db,
        sql => qq{ SELECT * FROM supplier WHERE $where },
        bind_values => $bind,
    });

    if ( defined $supplier and ref($supplier) eq 'ARRAY' and scalar @$supplier > 1 ) {
        $self->{supplier} = $supplier;
    } elsif ( defined $supplier and ref($supplier) eq 'ARRAY' and scalar @$supplier == 1 ) {
        $self->{supplier} = $supplier->[0];
    }
}

sub get_hash {
    my $self = shift;
    return $self->{supplier};
}

sub get_supplier {
    my $self = shift;
    my $args = shift || return $self->{supplier} || return {};
    return {} unless ref($args) eq 'HASH';

    if ( defined $args->{name} or defined $args->{id} ) {
        $self->_load($args);
    } else {
        return {};
    }

    return $self->get_hash();
}

sub create_supplier {
    my $self = shift;
    my $args = shift || return {};

    my @required_args = qw/name/;
    foreach my $k ( @required_args ) {
        return "'$k' was not defined in args" if not defined $args->{$k};
    }

    my $query = {
        db => $supplier_db,
        sql => qq{
            INSERT INTO supplier (name) VALUES(?)
        },
        bind_values => [ $args->{name} ],
    };

    $::DBS->execute($query);
}

sub _set_status {
    my $self = shift;
    my $args = shift;

    my $query = {
        db => $supplier_db,
        sql => qq{
            UPDATE supplier SET status = ? WHERE id = ?
        },
        bind_values => [ $args->{status}, $args->{id} ],
    };

    $::DBS->execute($query);
}

sub activate_supplier {
    my $self = shift;
    my $id   = shift || return "Please supply an user id";
    $self->_set_status({ id => $id, status => "Active" });
}

sub inactivate_supplier {
    my $self = shift;
    my $id   = shift || return "Please supply an user id";
    $self->_set_status({ id => $id, status => "Inactive" });
}

1;

__END__;

