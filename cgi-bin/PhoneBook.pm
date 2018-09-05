package PhoneBook;

use strict ;
use Data::Dumper;
use feature qw( state );
use Person;
use MyFile;


sub new {
    my $instance = shift;
    my $class    = ref $instance || $instance;
    my $self     = {};

    bless $self, $class;
    
    return $self->init( @_ );
}

sub init {
    my $self = shift;
    
    $self->{ localstorage } = $_[ 0 ]->{ localstorage } || 0 ;
    
    if ( $self->{ localstorage } ) {
        $self->{ storage } = {};
    }
    
    $self;
}


sub add_person {
    my $self = shift;    
    my $person = shift || return undef;
    
    state $add_user = {
        0 => sub { return $self->online_add_user( @_ ) },
        1 => sub { return $self->local_add_user( @_ ) },
    };

    return &{ $add_user->{ $self->{ localstorage } } }( $person );
}

sub bulk_add_user {
    print @Person::pparams ;
    
}

sub local_add_user {
    my $self        = shift;
    my $person_data = shift || return undef;

    my $user_id = $self->calculate_id_for_user();
    $self->{ storage }->{ $user_id } = Person->new( $person_data, { map { $_ => $self->{ $_ } } qw( localstorage ) } ); 
    return $self->{ storage }->{ $user_id };
}


sub online_add_user {
    my $self = shift;
    my $person_data = shift || {} ;

    return Person->new( $person_data, { map { $_ => $self->{ $_ } } qw( localstorage ) } ); 
}


sub calculate_id_for_user {
    my $self = shift;
    
    return rand;
}

sub read_user_data_from {
    
    
}

sub read_user_data_from_csv {
    my $self = shift;
    my $path = shift || "";
    
    my $file_content = MyFile::get_file_content( $path );
    my $parsed_user_data = [];
    my $result = 0;

    foreach my $line ( @{ $file_content } ) {
        my $person_data = {};
        @{ $person_data }{ @Person::pparams } = ( split ';', $line );
        
        ( $self->add_person( Person->new( $person_data ), { map { $_ => $self->{ $_ } } qw( localstorage ) } ) ) ? $result++ : $result;
    }
    
    return $result

}

1;


