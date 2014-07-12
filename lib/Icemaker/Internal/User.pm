package Icemaker::Internal::User;

use warnings;
use strict;

use Poet qw($conf $poet);
use Icemaker::Database::DBS;
use Data::Dumper;

my $user_db = $conf->get('db.user_db');

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
    foreach my $key ( qw/id username name/ ) {
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
 
    my $user = Icemaker::Database::DBS->new()->get_hasharray({
        db  => $user_db,
        sql => qq{ SELECT * FROM user WHERE $where },
        bind_values => $bind,
    });

    if ( defined $user and ref($user) eq 'ARRAY' and scalar @$user > 1 ) {
        $self->{user} = $user;
    } elsif ( defined $user and ref($user) eq 'ARRAY' and scalar @$user == 1 ) {
        $self->{user} = $user->[0];
    }
}

sub get_hash {
    my $self = shift;
    return $self->{user};
}

sub get_user {
    my $self = shift;
    my $args = shift || return $self->{user} || return {};
    return {} unless ref($args) eq 'HASH';

    if ( defined $args->{username} or defined $args->{name} or defined $args->{id} ) {
        $self->_load($args);
    } else {
        return {};
    }

    return $self->get_hash();
}

sub create_user {
    my $self = shift;
    my $args = shift || return {};

    my @required_args = qw/name username/;
    foreach my $k ( @required_args ) {
        return "'$k' was not defined in args" if not defined $args->{$k};
    }

    my $query = {
        db => $user_db,
        sql => qq{
            INSERT INTO user (name,username) VALUES(?, ?)
        },
        bind_values => [ $args->{name}, $args->{username} ],
    };

    Icemaker::Database::DBS->new()->execute($query);
}

sub get_user_by_username {
    my $self = shift;
    my $username = shift || return;
    
    my $user = Icemaker::Database::DBS->new()->get_hash({
        db  => $user_db,
        sql => qq{ SELECT * FROM user WHERE username = ? },
        bind_values => [ $username ],
    });

    return $user;
}

sub _set_status {
    my $self = shift;
    my $args = shift;

    my $query = {
        db => $user_db,
        sql => qq{
            UPDATE user SET status = ? WHERE id = ?
        },
        bind_values => [ $args->{status}, $args->{id} ],
    };

    Icemaker::Database::DBS->new()->execute($query);
}

sub delete_user {
    my $self = shift;
    my $id   = shift || return "Please supply an user id";
    $self->_set_status({ id => $id, status => "D" });
}

sub reactivate_user {
    my $self = shift;
    my $id   = shift || return "Please supply an user id";
    $self->_set_status({ id => $id, status => "Y" });
}

sub freeze_user {
    my $self = shift;
    my $id   = shift || return "Please supply an user id";
    $self->_set_status({ id => $id, status => "F" });
}

1;

__END__;

