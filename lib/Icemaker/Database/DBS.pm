package Icemaker::Database::DBS;

use Data::Dumper;
use JSON::XS;
use DBI qw(:sql_types);

my $dsn = 'dbi:mysql:';
my $user = "";#"mysql";
my $password = "123456";

# Make this package accessible through $::DBS
$::DBS = __PACKAGE__;

# Make JSON easilly available
$::JSON = JSON::XS->new();

sub new {
    my $self = shift;
    my $class = {};
    bless ( $class, $self );
    return $class;
}

sub _load {
    my $self = shift;
    my $args = shift || die "No args defined";

    my @validate = qw/db sql/;
    foreach my $k ( @validate ) {
        die "No $k defined" if not defined $args->{$k};
    }
    my $db   = $args->{db};
    my $sql  = $args->{sql};
    my $bind = defined $args->{bind_values} ? $args->{bind_values} : undef;
    $self->{_db} = $db;
    $self->{_sql} = $sql;
    $self->{_bind} = $bind;
}

sub _connect {
    my $self = shift;

    $self->{_DB} = DBI->connect_cached(
        $dsn."database=$self->{_db}",
        $user,
        $password
    ) || die "Connection Error: $DBI::errstr\n";
}

sub _pre_prepare {
    my $self = shift;
    return if not defined $self->{_bind};
    my $sql = $self->{_sql};
    my $bind = $self->{_bind};
    my $final_binds;
    foreach my $value ( @{$bind} ) {
        if ( ref($value) eq 'ARRAY' ) {
            my $binded = '\''.join ('\',\'', @$value) . '\'';
            $sql =~ s/\?\?/$binded/;
        } else {
            push @$final_binds, $value;
        }
    }
    $self->{_sql} = $sql;
    $self->{_bind} = $final_binds;
}

sub _prepare {
    my $self = shift;
    $self->{_prepare} = $self->{_DB}->prepare($self->{_sql});
}

sub _post_prepare {
    my $self = shift;
    if ( $self->{_bind} ) {
        my $p_num = 0;
        foreach my $value ( @{$self->{_bind}} ) { 
            $p_num++;
            $self->{_prepare}->bind_param($p_num, $value);
        }
    }
}

sub get_hasharray {
    my $self = shift;
    my $args = shift || die "No args defined";

    $self->_load($args);
    $self->_connect();
    $self->_pre_prepare();
    $self->_prepare();
    $self->_post_prepare();

    my $data;
    my $rr = $self->{_prepare};
    $rr->execute() || die "SQL Error: $DBI::errstr\n";
    while ( my $hr = $rr->fetchrow_hashref ) {
        push @$data, $hr;
    }
    return $data;
}

sub get_array {
    my $self = shift;
    my $args = shift || die "No args defined";

    $self->_load($args);
    $self->_connect();
    $self->_pre_prepare();
    $self->_prepare();
    $self->_post_prepare();

    my $array;
    my $rr = $self->{_prepare};
    $rr->execute() || die "SQL Error: $DBI::errstr\n";
    while (my $val = $rr->fetchrow_array ) {
        push @$array, $val;
    }
    return $array;
}

sub get_hash {
    my $self = shift;
    my $args = shift || die "No args defined";

    $self->_load($args);
    $self->_connect();
    $self->_pre_prepare();
    $self->_prepare();
    $self->_post_prepare();

    my $rr = $self->{_prepare};
    $rr->execute() || die "SQL Error: $DBI::errstr\n";
    my $data = $rr->fetchrow_hashref;
    return $data;
}

sub execute {
    my $self = shift;
    my $args = shift || die "No args defined";

    $self->_load($args);
    $self->_connect();
    $self->_pre_prepare();
    $self->_prepare();
    $self->_post_prepare();
    my $rr = $self->{_prepare};
    $rr->execute() || die "SQL Error: $DBI::errstr\n";
}

# TODO: db => 'xyz' will convert to a database to be used in $dsn .= $database

1;

