package Icemaker::Internal::Login;

use strict;
use warnings;

use Poet qw($conf $poet);
use Digest::MD5 qw(md5);
use Icemaker::Internal::Permissions;
use Icemaker::Database::DBS;

my $user_db = $conf->get('db.user_db');

sub login {
    my $self = shift;
    my $username = shift || return 0;
    my $password = shift || return 0;

    my $user = Icemaker::Database::DBS->new()->get_hash({
        db  => $user_db,
        sql => qq{
            SELECT * 
            FROM user 
            WHERE username = ? 
                AND password = ? 
                AND status = ?
        },
        bind_values => [ $username, $self->_hashed($password), "Y" ],
    });

    # Ensure any newly added premission properties are available
    Icemaker::Internal::Permissions->new($user->{id})->grant_basics(); 

    return 1 if defined $user and defined $user->{username};
    return 0;
}

sub logout {
    my $self = shift;
    my $m = shift || return;
    foreach my $k ( keys %{$m->session} ) {
        delete($m->session->{$k});
    }
}

sub load_user {
    my $self = shift;
    my $m = shift || return;
    my $username = shift || return;
    $m->session->{user_access} = Icemaker::Internal::Permissions->load_session_for_username($username);
}

sub _salt {
    my $self = shift;
    return '$GB#/gr%';
}

sub _hashed {
    my $self = shift;
    my $pass = shift;
    return md5($self->_salt().$pass);
}

# Can only set password for existing users
sub set_password {
    my $self = shift;
    my $username = shift || return 0;
    my $password = shift || return 0;
    return 0 unless valid_password($password);

    my $user = Icemaker::Database::DBS->new()->get_hash({
        db  => $user_db,
        sql => qq{
            SELECT * 
            FROM user 
            WHERE username = ? 
        },
        bind_values => [ $username, ],
    });

    if ( defined $user and defined $user->{id} ) {
        Icemaker::Database::DBS->new()->execute({
            db  => $user_db,
            sql => qq{
                UPDATE user 
                SET status = ?, password = ?
                WHERE id = ?
            },
            bind_values => [ "Y", $self->_hashed($password), $user->{id} ],
        });
    
        my $user_access = Icemaker::Database::DBS->new()->get_hash({
            db  => $user_db,
            sql => qq{
                SELECT COUNT(*) cnt
                FROM user_access
                WHERE user_id = ?
            },
            bind_values => [ $user->{id}, ],
        });
    }

    return 1; 
}

sub valid_password {
    my $password = shift || return 0;
    my $result;
    return 0 if length($password) < 6;
    return 0 unless $password =~ m/[#!\&\$\%]/;
    return 1;
}

1;
