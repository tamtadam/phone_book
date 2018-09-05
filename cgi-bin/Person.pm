package Person;

use strict ;
use feature qw( state );
use Data::Dumper;
use Person;
use DBH;
our @ISA = qw( DBH );

our @pparams = qw( UserID Email LastName ForName );

sub new {
    my $instance = shift;
    my $class    = ref $instance || $instance;
    
    my $self     = {
        map { $_ => undef }  @pparams
    };
    
    bless $self, $class;

    $self->{ localstorage } = $_[ 1 ]->{ localstorage } || 0 ;
    $self->init( @_ );

    $self;
}

sub init {
    my $self = shift;
    
    $self->create_user( @_ );

    return $self;
}


sub create_user {
    my $self = shift;

    state $Email = {
        0 => sub { $self->online_create_user( @_ ) },
        1 => sub { $self->update_user_params( @_ ) },
    };
    
    if ( @_ ) {
        &{ $Email->{ $self->{ localstorage } } }( @_ );
    }
}


sub online_create_user {
    my $self = shift;
    my $user_data = shift || {};

    my $res = $self->my_select( {
        from => 'user',
        where => {
            Email => $user_data->{ Email },
        }
    } );

    if ( $res ) {
        $self->update_user_params( $res->[ 0 ] ) ;
        
    } else {
        $res = $self->my_insert( {
            table => 'user',
            insert => $user_data
        } );
    }
}


sub update_user_params {
    my $self = shift;
    my $user_data = shift || {} ;

    $self->{ $_ } = $user_data->{ $_ } foreach @pparams;
    
    return $self;
}


sub id {
    my $self = shift;
    
    return $self->{ UserID };
}


sub Email {
    my $self = shift;
    
    state $Email = {
        0 => sub { return $self->online_email( @_ ) },
        1 => sub { return $self->local_email( @_ ) },
    };
    
    if ( @_ ) {
        &{ $Email->{ $self->{ localstorage } } }( @_ );
    }

    return $self->{ Email };
}

sub local_email {
    my $self = shift;
    $self->{ Email } = shift || 'NotSet';
    return $self->{ Email }
}


sub online_email{
    my $self = shift ;

    my $res = $self->my_update( {
        "table"  => "user",
        "update" => {
            "Email" => $_[ 0 ],
        },
        "where" => {
            "UserID" => $self->id() ,
        }
    } ) ;

    if( $res ){
        $self->{ 'Email' } = $_[ 0 ] ;
        return 1;
        
    } else {
        return undef;
        
    }
}


1;