package Icemaker::Internal::Ingredient;

use warnings;
use strict;

use Poet qw($conf $poet);
use Icemaker::Database::DBS;
use Data::Dumper;

my $ingredient_db = $conf->get('db.ingredient_db');

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
 
    my $ingredient = Icemaker::Database::DBS->new()->get_hasharray({
        db  => $ingredient_db,
        sql => qq{ SELECT * FROM ingredient WHERE $where },
        bind_values => $bind,
    });

    if ( defined $ingredient and ref($ingredient) eq 'ARRAY' and scalar @$ingredient > 1 ) {
        $self->{ingredient} = $ingredient;
    } elsif ( defined $ingredient and ref($ingredient) eq 'ARRAY' and scalar @$ingredient == 1 ) {
        $self->{ingredient} = $ingredient->[0];
    }
}

sub get_hash {
    my $self = shift;
    return $self->{ingredient};
}

sub get_ingredient {
    my $self = shift;
    my $args = shift || return $self->{ingredient} || return {};
    return {} unless ref($args) eq 'HASH';

    if ( defined $args->{name} or defined $args->{id} ) {
        $self->_load($args);
    } else {
        return {};
    }

    return $self->get_hash();
}

sub create_ingredient {
    my $self = shift;
    my $args = shift || return {};

    my @required_args = qw/name/;
    foreach my $k ( @required_args ) {
        return "'$k' was not defined in args" if not defined $args->{$k};
    }

    my $query = {
        db => $ingredient_db,
        sql => qq{
            INSERT INTO ingredient (name) VALUES(?)
        },
        bind_values => [ $args->{name} ],
    };

    Icemaker::Database::DBS->new()->execute($query);
}

sub _set_status {
    my $self = shift;
    my $args = shift;

    my $query = {
        db => $ingredient_db,
        sql => qq{
            UPDATE ingredient SET status = ? WHERE id = ?
        },
        bind_values => [ $args->{status}, $args->{id} ],
    };

    Icemaker::Database::DBS->new()->execute($query);
}

sub activate_ingredient {
    my $self = shift;
    my $id   = shift || return "Please supply an user id";
    $self->_set_status({ id => $id, status => "Active" });
}

sub inactivate_ingredient {
    my $self = shift;
    my $id   = shift || return "Please supply an user id";
    $self->_set_status({ id => $id, status => "Inactive" });
}

1;

__END__;

