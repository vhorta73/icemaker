package Icemaker::Internal::DB::Operator;

use Icemaker::Internal::DB::Schema;
use Poet qw($conf);
use Moose;

sub get_all_active {
    my $self = shift;
    my $sources_all = $::DBIx->resultset('Operator')->search({ status => 'Active' });
    my $list;
    while ( my $row = $sources_all->next ) {
        my $hash;
        foreach my $k ( $row->columns ) {
            $hash->{$k} = $row->get_column($k);
        }
        push @$list, $hash;
    }
    return $list;
}

sub get_all_inactive {
    my $self = shift;
    my $sources_all = $::DBIx->resultset('Operator')->search({ status => 'Inactive' });
    my $list;
    while ( my $row = $sources_all->next ) {
        my $hash;
        foreach my $k ( $row->columns ) {
            $hash->{$k} = $row->get_column($k);
        }
        push @$list, $hash;
    }
    return $list;
}

sub activate {
    my $self = shift;
    my $first_name = shift || die "No first name supplied";
    my $last_name  = shift || die "No last name supplied";
    $self->_activate_inactivate("Active",$first_name,$last_name);
}

sub inactivate {
    my $self = shift;
    my $first_name = shift || die "No first name supplied";
    my $last_name  = shift || die "No last name supplied";
    $self->_activate_inactivate("Inactive",$first_name,$last_name);
}

sub _activate_inactivate {
    my $self = shift;
    my $action = shift || die "Action expected [Active|Inactive]";
    my $first_name = shift || die "No first name supplied";
    my $last_name  = shift || die "No last name supplied";

    my $sources = $::DBIx->resultset('Operator')->find({ first_name => $first_name, last_name => $last_name });
    if ( defined $sources ) {
        $sources->update({ status => $action });
    }
    else {
        $self->_new($first_name,$last_name,$action);
    }
}

sub _new {
    my $self = shift;
    my $first_name = shift || die "No first name supplied";
    my $last_name = shift || die "No last name supplied";
    my $status = shift || "Active";

    my $sources = $::DBIx->resultset('Operator')->new({ 
        first_name => $first_name, 
        last_name => $last_name, 
        status => $status 
    });

    if ( $sources->in_storage() ) {
        die "Already in storage";
    }
    else {
        $sources->update();
    }
}


1;
