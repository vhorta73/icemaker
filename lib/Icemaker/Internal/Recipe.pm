package Icemaker::Internal::Recipe;

use warnings;
use strict;

use Poet qw($conf $poet);

my $recipe_db = $conf->get('db.recipe_db');

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
    foreach my $key ( qw/id name notes/ ) {
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

    my $recipe = $::DBS->get_hasharray({
        db  => $recipe_db,
        sql => qq{ SELECT * FROM recipe WHERE $where },
        bind_values => $bind,
    });

    if ( defined $recipe and ref($recipe) eq 'ARRAY' and scalar @$recipe > 1 ) {
        $self->{recipe} = $recipe;
    } elsif ( defined $recipe and ref($recipe) eq 'ARRAY' and scalar @$recipe == 1 ) {
        $self->{recipe} = $recipe->[0];
    }
}

sub get_hash {
    my $self = shift;
    return $self->{recipe};
}

sub get_recipe {
    my $self = shift;
    my $args = shift || return $self->{recipe} || return {};
    return {} unless ref($args) eq 'HASH';

    if ( defined $args->{name} or defined $args->{id} ) {
        $self->_load($args);
    } else {
        return {};
    }

    return $self->get_hash();
}

sub create_recipe {
    my $self = shift;
    my $args = shift || return {};

    my @required_args = qw/name/;
    foreach my $k ( @required_args ) {
        return "'$k' was not defined in args" if not defined $args->{$k};
    }

    my $query = {
        db => $recipe_db,
        sql => qq{
            INSERT INTO recipe (name) VALUES(?)
        },
        bind_values => [ $args->{name} ],
    };

    $::DBS->execute($query);
}

sub _set_status {
    my $self = shift;
    my $args = shift;

    my $query = {
        db => $recipe_db,
        sql => qq{
            UPDATE recipe SET status = ? WHERE id = ?
        },
        bind_values => [ $args->{status}, $args->{id} ],
    };

    $::DBS->execute($query);
}

sub activate_recipe {
    my $self = shift;
    my $id   = shift || return "Please supply an user id";
    $self->_set_status({ id => $id, status => "Active" });
}

sub inactivate_recipe {
    my $self = shift;
    my $id   = shift || return "Please supply an user id";
    $self->_set_status({ id => $id, status => "Inactive" });
}

1;

__END__;

