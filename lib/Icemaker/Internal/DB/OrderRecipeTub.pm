package Icemaker::Internal::DB::OrderRecipeTub;

use Icemaker::Internal::DB::Schema;
use Poet qw($conf);
use Moose;

extends 'Icemaker::Internal::DB::Base';

use constant TABLE => "OrderRecipeTub";

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->_table(TABLE);
    return $self;
}

1;
