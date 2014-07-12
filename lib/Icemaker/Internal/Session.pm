package Icemaker::Internal::Session;

use strict;
use warnings;

use Poet::Script qw($conf);

my $user_db = $conf->get('db.user_db');

sub new {
    my $self = shift;
    my $class = {};
    my $data = shift;
    $class->{data} = $data;
    bless($class, $self);
    return $class;
}

sub can {
    my $self = shift;
    my $label = shift || return 0;
    my $level = shift || 0;

    if ( defined $self and defined $self->{data} and defined $self->{data}->{$label} ) {
        if ( $level > 0 ) {
            # level set on DB much be higher or equal than the inquired
            if ( $self->{data}->{$label} >= $level ) {
                return 1;
            } else {
                return 0;
            }
        } else {
            return 1;
        }
    }
    return 0;
}

sub load_user_session {
    my $self = shift;
    my $m = shift || return;
    my $username = shift || return;

    my $user_data = $::DBS->get_hash({
        db  => $user_db,
        sql => qq{
            SELECT * 
            FROM user  
            WHERE username = ? 
        },
        bind_values => [ $username ],
    });

    delete($user_data->{password});

    my $access = $::DBS->get_hasharray({
        db  => $user_db,
        sql => qq{
            SELECT ua.label, ua.level 
            FROM user u 
            JOIN user_access ua 
                ON u.id = ua.user_id 
            WHERE u.id = ? 
                AND ua.authorized = 'Y'
        },
        bind_values => [ $user_data->{id} ],
    });

    my $user_access;
    foreach my $data ( @$access ) {
        $user_access->{$data->{label}} = $data->{level};
    }

    my $new = Icemaker::Internal::Session->new($user_access);
    $m->session->{user_access} = $new;
    $m->session->{user_data} = $user_data;
}

1;

