package CIF::WebAPI;
use base 'Apache2::REST::Handler';

use 5.008008;
use strict;
use warnings;

use Data::Dumper;
use CIF::Message::Structured;

our $VERSION = '0.00_02';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

sub GET {
    my ($self,$request,$response) = @_;
    $request->requestedFormat('json');
    return Apache2::Const::HTTP_OK;
}

sub aggregateFeed {
    my $key = shift;
    my @recs = @_;
    
    my $hash;
    my @feed;
    foreach (@recs){
        if(exists($hash->{$_->$key()})){
            if($_->restriction() eq 'private'){
                next unless($_->restriction() eq 'need-to-know');
            }
        }
        $hash->{$_->$key()} = $_;
    }
    foreach (keys %$hash){
        my $rec = $hash->{$_};
        push(@feed, mapIndex($rec));
    }
    return(\@feed);
}

sub mapIndex {
    my $rec = shift;
    my $msg = CIF::Message::Structured->retrieve(uuid => $rec->uuid->id());
    $msg = $msg->message();
    return {
        rec         => $rec,
        restriction => $rec->restriction(),
        severity    => $rec->severity(),
        impact      => $rec->impact(),
        confidence  => $rec->confidence(),
        description => $rec->description(),
        detecttime  => $rec->detecttime(),
        uuid        => $rec->uuid->id(),
        alternativeid   => $rec->alternativeid(),
        alternativeid_restriction   => $rec->alternativeid_restriction(),
        created     => $rec->created(),
        message     => $msg,
    };
}

sub isAuth {
    my ($self,$method,$req) = @_;
    return ($method eq 'GET');
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::WebAPI - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CIF::WebAPI;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for CIF::WebAPI, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Wes Young, E<lt>wes@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Wes Young
Copyright (C) 2010 by REN-ISAC and The Trustees of Indiana University 

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
