package Icemaker::Internal::Orders;

use warnings;
use strict;

use Poet qw($conf $poet);

my $orders_db = $conf->get('db.orders_db');

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
    foreach my $key ( qw/id customer_id/ ) {
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
 
    my $orders = $::DBS->get_hasharray({
        db  => $orders_db,
        sql => qq{ SELECT * FROM orders WHERE $where },
        bind_values => $bind,
    });

    if ( defined $orders and ref($orders) eq 'ARRAY' and scalar @$orders > 1 ) {
        $self->{orders} = $orders;
    } elsif ( defined $orders and ref($orders) eq 'ARRAY' and scalar @$orders == 1 ) {
        $self->{orders} = $orders->[0];
    }
}

sub get_hash {
    my $self = shift;
    return $self->{orders};
}

sub get_orders {
    my $self = shift;
    my $args = shift || return $self->{orders} || return {};
    return {} unless ref($args) eq 'HASH';

    if ( defined $args->{customer_id} or defined $args->{id} ) {
        $self->_load($args);
    } else {
        return {};
    }

    return $self->get_hash();
}

sub create_order {
    my $self = shift;
    my $args = shift || return {};

    my @required_args = qw/customer_id/;
    foreach my $k ( @required_args ) {
        return "'$k' was not defined in args" if not defined $args->{$k};
    }

    my $query = {
        db => $orders_db,
        sql => qq{
            INSERT INTO orders (customer_id) VALUES(?)
        },
        bind_values => [ $args->{customer_id} ],
    };

    $::DBS->execute($query);
}

sub _set_status {
    my $self = shift;
    my $args = shift;

    my $query = {
        db => $orders_db,
        sql => qq{
            UPDATE orders SET status = ? WHERE id = ?
        },
        bind_values => [ $args->{status}, $args->{id} ],
    };

    $::DBS->execute($query);
}

sub set_save {
    my $self = shift;
    my $id   = shift || return "Please supply an orders id";
    $self->_set_status({ id => $id, status => "saved" });
}

sub set_cancelled {
    my $self = shift;
    my $id   = shift || return "Please supply an orders id";
    $self->_set_status({ id => $id, status => "cancelled" });
}

sub set_queued {
    my $self = shift;
    my $id   = shift || return "Please supply an orders id";
    $self->_set_status({ id => $id, status => "queued" });
}

sub set_in_progress {
    my $self = shift;
    my $id   = shift || return "Please supply an orders id";
    $self->_set_status({ id => $id, status => "in progress" });
}

sub set_pending {
    my $self = shift;
    my $id   = shift || return "Please supply an orders id";
    $self->_set_status({ id => $id, status => "pending" });
}

sub set_completed {
    my $self = shift;
    my $id   = shift || return "Please supply an orders id";
    $self->_set_status({ id => $id, status => "completed" });
}

sub set_closed {
    my $self = shift;
    my $id   = shift || return "Please supply an orders id";
    $self->_set_status({ id => $id, status => "closed" });
}


1;

__END__;

