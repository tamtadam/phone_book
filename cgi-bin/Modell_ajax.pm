package Modell_ajax;
use strict;
use Data::Dumper;

use Person      ;
use PhoneBook   ;
use Errormsg    ;
use Log         ;
use OBJECTS     ;
use feature qw(state);
use DBDispatcher qw( convert_sql );

our @ISA = qw( Person PhoneBook Errormsg Log Errormsg OBJECTS) ;

sub new {
    my ($class) = shift;

    my $self = {};
    bless( $self, $class );
    $self->init( @_ );
    return $self;
}

sub init {
    my $self = shift;
    $self->{ $_ } = $_[ 0 ]->{ $_ } for qw(DB_HANDLE DB_Session);
    return $self;
}


sub get_all_status {
    my $self = shift;
    my $res = $self->my_select( {
        'from'   => 'v_relay_params_detailed' ,
        'select' => 'ALL'
    } );
    my $ordered = {};

    for my $db_row ( @{ $res } ) {
        $ordered->{ $db_row->{ 'relay_name' }  }{ $db_row->{ 'name' } } = $db_row->{ 'value' };
        $ordered->{ $db_row->{ 'relay_name' }  }{ 'timestamp' } = $db_row->{ 'last_update' };
    }

    return $ordered;
}


1;
