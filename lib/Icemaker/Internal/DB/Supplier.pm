package Icemaker::Internal::DB::Supplier;

use Icemaker::Internal::DB::Schema;
use Poet qw($conf);
use Moose;

extends 'Icemaker::Internal::DB::Base';

use constant TABLE => "Supplier";

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->_table(TABLE);
    return $self;
}

1;
