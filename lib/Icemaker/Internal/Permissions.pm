package Icemaker::Internal::Permissions;

use warnings;
use strict;

use Poet::Script qw($conf $poet);

use constant {
    MAX_ACCESS_LEVEL => 3,
};

my $user_db = $conf->get('db.user_db');
my @basics = qw/recipeorders suppliers users machines ingredients packages recipes customers/;

sub new {
    my $self = shift;
    my $user_id = shift;
    my $class = {}; 
    bless ( $class, $self );
    $class->_load($user_id) if defined $user_id;
    return $class;
}

sub _load {
    my $self = shift;
    my $user_id = shift;

    $self->{id} = $user_id;
    my $query = {
        db => $user_db,
        sql => qq{
            SELECT * FROM user_access WHERE user_id = ?
        },
        bind_values => [ $self->{id} ],
    };
    my $user_access = $::DBS->get_hasharray($query);

    foreach my $h ( @$user_access ) {
        $self->{user_access}->{$h->{label}} = $h;
    }
}

sub _can {
    my $self = shift;
    my $label = shift;
    return $self->{user_access}->{$label}->{authorized};
}

sub has_permission {
    my $self  = shift;
    my $label = shift || return "Please supply access label";
    return "User ID not found, object not initialized" if not defined $self->{id} and not defined $self->{user_access};
    return $self->_can($label) || 0;
}

sub grant_permission {
    my $self = shift;
    my $label = shift || return "Please supply access label";
    my $level = shift || 1;
    return "User ID not found, object not initialized" if not defined $self->{id} and not defined $self->{user_access};
    my $query = {
        db => $user_db,
        sql => qq{
            SELECT * FROM user_access WHERE user_id = ? AND label = ?
        },
        bind_values => [ $self->{id}, $label ],
    };

    if ( my $existing = $::DBS->get_hash($query) ) {
        my $query = {
            db => $user_db,
            sql => qq{
                UPDATE user_access 
                SET authorized = ? 
                WHERE user_id = ? AND label = ?
            },
            bind_values => [ "Y", $self->{id}, $label ],
        };
        $::DBS->execute($query);

    } else {
        my $query = {
            db => $user_db,
            sql => qq{
                INSERT INTO user_access (user_id,label,authorized,level) VALUES(?, ?, ?, ?)
            },
            bind_values => [ $self->{id}, $label, "Y", $level ],
        };
        $::DBS->execute($query);
    }
}

sub revoke_permission {
    my $self = shift;
    my $label = shift || return "Please supply access label";
    return "User ID not found, object not initialized" if not defined $self->{id} and not defined $self->{user_access};
    my $query = {
        db => $user_db,
        sql => qq{
            SELECT * FROM user_access WHERE user_id = ? AND label = ?
        },
        bind_values => [ $self->{id}, $label ],
    };

    # If not existing, not permissions exist to be revoked
    if ( my $existing = $::DBS->get_hash($query) ) {
        my $query = {
            db => $user_db,
            sql => qq{
                UPDATE user_access 
                SET authorized = ? 
                WHERE user_id = ? AND label = ?
            },
            bind_values => [ "N", $self->{id}, $label ],
        };
        $::DBS->execute($query);
    }
}

# Auto-create missing permissions for users.
sub grant_basics {
    my $self = shift;
    return if not defined $self->{id};
    my $user = $::DBS->get_hash({
        db  => $user_db,
        sql => qq{ SELECT username FROM user WHERE id = ? },
        bind_values => [ $self->{id} ],
    });

    foreach my $label ( @basics ) {
        my $query = {
            db  => $user_db,
            sql => qq{
                 SELECT * FROM user_access WHERE user_id = ? AND label = ? 
            },
            bind_values => [ $self->{id}, $label ],
        };

        my $exists = $::DBS->get_hash($query);
        if ( defined $exists and $exists->{user_id} ) {

        } else {
            $query = {
                db  => $user_db,
                sql => qq{
                     INSERT INTO user_access ( user_id, label ) VALUES (?, ?) 
                },
                bind_values => [ $self->{id}, $label ],
            };
        }
        $::DBS->execute($query);
    }

    # Ensure that the master user is always available
    if ( lc($user->{username}) eq 'master' ) {
        my $query = {
            db  => $user_db,
            sql => qq{ UPDATE user_access SET level = ?, authorized = ? WHERE user_id = ? },
            bind_values => [ MAX_ACCESS_LEVEL + 1, 'Y', $self->{id}, ],
        };
        $::DBS->execute($query);
    }
}

1;

__END__;

