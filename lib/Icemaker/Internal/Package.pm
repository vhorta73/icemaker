package Icemaker::Internal::Package;

use warnings;
use strict;

use Poet qw($conf $poet);
use Icemaker::Database::DBS;
use Data::Dumper;

my $package_db = $conf->get('db.package_db');

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
    foreach my $key ( qw/id name size units/ ) {
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
 
    my $package = Icemaker::Database::DBS->new()->get_hasharray({
        db  => $package_db,
        sql => qq{ SELECT * FROM package WHERE $where },
        bind_values => $bind,
    });

    if ( defined $package and ref($package) eq 'ARRAY' and scalar @$package > 1 ) {
        $self->{package} = $package;
    } elsif ( defined $package and ref($package) eq 'ARRAY' and scalar @$package == 1 ) {
        $self->{package} = $package->[0];
    }
}

sub get_hash {
    my $self = shift;
    return $self->{package};
}

sub get_package {
    my $self = shift;
    my $args = shift || return $self->{package} || return {};
    return {} unless ref($args) eq 'HASH';

    if ( defined $args->{size} or defined $args->{id} ) {
        $self->_load($args);
    } else {
        return {};
    }

    return $self->get_hash();
}

sub create_package {
    my $self = shift;
    my $args = shift || return {};

    my @required_args = qw/name/;
    foreach my $k ( @required_args ) {
        return "'$k' was not defined in args" if not defined $args->{$k};
    }

    my $query = {
        db => $package_db,
        sql => qq{
            INSERT INTO package (name) VALUES(?)
        },
        bind_values => [ $args->{name} ],
    };

    Icemaker::Database::DBS->new()->execute($query);
}

sub _set_status {
    my $self = shift;
    my $args = shift;

    my $query = {
        db => $package_db,
        sql => qq{
            UPDATE package SET status = ? WHERE id = ?
        },
        bind_values => [ $args->{status}, $args->{id} ],
    };

    Icemaker::Database::DBS->new()->execute($query);
}

sub activate_package {
    my $self = shift;
    my $id   = shift || return "Please supply an user id";
    $self->_set_status({ id => $id, status => "Active" });
}

sub inactivate_package {
    my $self = shift;
    my $id   = shift || return "Please supply an user id";
    $self->_set_status({ id => $id, status => "Inactive" });
}

1;

__END__;

