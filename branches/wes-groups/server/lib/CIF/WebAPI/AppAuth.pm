package CIF::WebAPI::AppAuth ;

use warnings ;
use strict ;
use CIF::WebAPI::APIKey;

use Apache2::Const qw(:common :http);

=head1 NAME

CIF::WebAPI::AppAuth - Base class for application authentication

=cut


=head2 new

Returns a new instance of this class.

If you override this, remember it is called without
arguments by the framework.


=cut

sub new {
    my ( $class ) = @_ ;
    return bless {} , $class ;
}

=head2 init

Override this if you want to initialise this plugin
with properties accessible through the Apache2::Request 

Called by the framework like this:

    $this->init($req) ;

=cut

sub init{
    my ( $self , $req ) = @_ ;
    # Nothing by default
}



=head2 authorize

Implement this to let the Application authentifier
decide if the application can access the API or not.

Please set resp->status() and resp->message() ;

Returns true if authorized. False otherwise.

Called like this by the framework:

$this->authorize($req , $resp ) ;

=cut

sub authorize {
    my ( $self , $req , $resp ) = @_ ;
    my $key = lc($req->param('apikey'));
    
    # test1
    return(0) unless ($key && $key =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/);

    # what part of the api are we accessing
    my $uri = $req->uri();
    if(my $base = $req->dir_config('Apache2RESTAPIBase')){
        $uri =~ s/^\Q$base\E//;
    }
    my @stack = split('\/+' , $uri);
    @stack = grep { length($_)>0 } @stack;

    my $rec = CIF::WebAPI::APIKey->retrieve(apikey => $key);
    return(0) unless($rec); # no keys
    return(0) if($rec->revoked()); # revoked keys
    return(0) unless($rec->access());
    return(0) unless($rec->access() eq 'all' || $rec->access() eq $stack[0]); # ACL
    
    return(1); # all good
}


1;
