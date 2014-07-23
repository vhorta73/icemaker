package Icemaker::Internal::DB::Base;

use Icemaker::Internal::DB::Schema;
use Poet qw($conf);
use Moose;

has '_table', is => 'rw', isa => 'Str', required => 1;

=pod get_one

Paramenters: %args with table columns and data. 
Returns: {}

=cut

sub get_one {
    my $self = shift;
    my %args = (@_);
    my $sources  = $::DBIx->resultset($self->_table)->find(\%args);
    return $self->_hash($sources);
}

=pod get_hasharray

Paramenters: %args with table columns and data. 
Returns: [{}]

=cut

sub get_hasharray {
    my $self = shift;
    my %args = (@_);
    my $sources  = $::DBIx->resultset($self->_table)->search(\%args);
    return $self->_hash_array($sources);
}

=pod get_all_active

Returns all status Active records for $self->_table

=cut

sub get_all_active {
    my $self = shift;
    return $self->get_hasharray(status => "Active");
}

=pod get_all_inactive

Returns all status Inactive records for $self->_table

=cut

sub get_all_inactive {
    my $self = shift;
    return $self->get_hasharray(status => 'Inactive');
}

sub activate {
    my $self = shift;
    my %args = (@_);
    my $sources = $::DBIx->resultset($self->_table)->search(\%args);
        
    if ( defined $sources ) {
        $sources->update({ status => 'Active' });
    }
    else {
        $sources = $::DBIx->resultset($self->_table)->new(\%args);
        $sources->update() unless $sources->in_storage();
    }
}

sub deactivate {
    my $self = shift;
    my %args = (@_);
    my $sources = $::DBIx->resultset($self->_table)->search(\%args);
        
    if ( defined $sources ) {
        $sources->update({ status => 'Inactive' });
    }
    else {
        $sources = $::DBIx->resultset($self->_table)->new(\%args);
        $sources->update() unless $sources->in_storage();
    }
}

sub create_new {
    my $self = shift;
    my %args = (@_);
    my $sources = $::DBIx->resultset($self->_table)->find(\%args);
    
    if ( defined $sources ) {
        $sources->update({ status => 'Active' });
    }
    else {
        $sources = $::DBIx->resultset($self->_table)->new(\%args);
        if( $sources->in_storage() ) {
            $sources->update();
        }
        else {
            $sources->insert();
        }
    }
}

=pod _hash_array

Given a DBIx search resultset, returns a [{}].

=cut

sub _hash_array {
    my $self = shift;
    my $sources = shift;
    return [] unless $sources;
    my $list;
    while ( my $row = $sources->next ) {
        my $hash;
        foreach my $k ( $row->columns ) {
            $hash->{$k} = $row->get_column($k);
        }
        push @$list, $hash;
    }
    return $list;
}

=pod _hash

Given a DBIx find resultset, returns a {}.

=cut

sub _hash {
    my $self = shift;
    my $sources = shift;
    return {} unless $sources;
    my $hash;
        foreach my $k ( $sources->columns ) {
            $hash->{$k} = $sources->get_column($k);
        }
    return $hash;
}

1;
