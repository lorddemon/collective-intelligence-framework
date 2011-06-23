package CIF::Utils;

use 5.008008;
use strict;
use warnings;

use DateTime::Format::DateParse;
use OSSP::uuid;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration   use CIF::Utils ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(isUUID genMessageUUID genUUID genSourceUUID throttle split_batches normalize_timestamp) ] );
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT = qw//;

our $VERSION = '0.01_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

=head1 NAME

CIF::Utils - Perl extension for misc 'helper' CIF like functions

=head1 SYNOPSIS

  use CIF::Utils;
  use Data::Dumper;

  my $dt = time()
  $dt = CIF::Utils::normalize_timestamp($dt);
  warn $dt;

  my $uuid = genUUID();
  my $uuid = genSourceUUID('example.com');
  my $uuid = genMessageUUID($source,$json_text);

  my $throttle = throttle('medium');

=head1 DESCRIPTION
 
  These are mostly helper functions to be used within CIF::Archive. We did some extra work to better parse timestamps and provide some internal uuid, cpu throttling and thread-batching for various CIF functions.

=head1 Functions

=over

=item isUUID($uuid)

  Returns 1 if the argument matches /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
  Returns 0 if it doesn't

=cut

sub isUUID {
    my $arg = shift;
    return undef unless($arg);
    return undef unless($arg =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/);
    return(1);
}

=item genMessageUUID($source,$msg)

  generates a "v5" uuid and returns it as a string

=cut

sub genMessageUUID {
    my ($source,$msg) = @_;
    return undef unless($msg && $source);

    my $uuid = new OSSP::uuid();
    my $uuid_ns = new OSSP::uuid();
    $uuid_ns->load("UUID_NIL");
    $uuid->make("v5", $uuid_ns, $source.$msg);
    undef $uuid_ns;
    my $str = $uuid->export("str");
    undef $uuid;
    return($str);
}

=item genUID()

  generates a random "v4" uuid and returns it as a string

=cut

sub genUUID {
    my $uuid    = OSSP::uuid->new();
    $uuid->make('v4');
    my $str = $uuid->export('str');
    undef $uuid;
    return($str);
}

=item genSourceUUID($source)

  generates and returns a "v3" uuid based on the source (domain namespace, eg: example.com)

=cut

sub genSourceUUID {
    my $source = shift;
    my $uuid = OSSP::uuid->new();
    my $uuid_ns = OSSP::uuid->new();
    $uuid_ns->load('ns::URL');
    $uuid->make("v3",$uuid_ns,$source);
    my $str = $uuid->export('str');
    undef $uuid;
    return($str);
}

=item throttle([high|medium|low])

  returns the number of course to be used given a "throttle"
  low:      $CORES x 0.5
  medium:   $CORES x 1
  high:     $cores x 1.5
 
=cut

sub throttle {
    my $throttle = shift;

    require Linux::Cpuinfo;
    my $cpu = Linux::Cpuinfo->new();
    return(1) unless($cpu);
    my $cores = $cpu->num_cpus();
    return(1) unless($cores && $cores =~ /^\d$/);
    return(1) if($cores eq 1);
    return($cores) unless($throttle && $throttle ne 'medium');
    return($cores/2) if($throttle eq 'low');
    return($cores * 1.5);
}

=item split_batches($threads,$recs)

  Takes in a threads count (number of threads to use) and an array reference of arrays to be split evenly
  returns an ARRAYREF of evenly distributed arrays to be processed

=cut

sub split_batches {
    ## TODO -- think through this.
    my $tc = shift;
    my $recs = shift || return;
    my @array = @$recs;

    my @batches;
    if($#array == 0){
        push(@batches,$recs);
        return(\@batches);
    }

    my $num_recs = $#array + 1;
    my $batch = (($num_recs/$tc) == int($num_recs/$tc)) ? ($num_recs/$tc) : (int($num_recs/$tc) + 1);
    for(my $x = 0; $x <= $#array; $x += $batch){
        my $start = $x;
        my $end = ($x+$batch);
        $end = $#array if($end > $#array);
        my @a = @array[$x ... $end];
        push(@batches,\@a);
        $x++;
    }
    return(\@batches);
}

=item normalize_timestamp($ts)

  Takea in a timestamp (see DateTime::Format::DateParse), does a little extra normalizing and returns a DateTime object

=cut

sub normalize_timestamp {
    my $dt = shift;
    return $dt if($dt =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/);
    if($dt && ref($dt) ne 'DateTime'){
        if($dt =~ /^\d+$/){
            if($dt =~ /^\d{8}$/){
                $dt.= 'T00:00:00Z';
                $dt = eval { DateTime::Format::DateParse->parse_datetime($dt) };
                unless($dt){
                    $dt = DateTime->from_epoch(epoch => time());
                }
            } else {
                $dt = DateTime->from_epoch(epoch => $dt);
            }
        } elsif($dt =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(\S+)?$/) {
            my ($year,$month,$day,$hour,$min,$sec,$tz) = ($1,$2,$3,$4,$5,$6,$7);
            $dt = DateTime::Format::DateParse->parse_datetime($year.'-'.$month.'-'.$day.' '.$hour.':'.$min.':'.$sec,$tz);
        } else {
            $dt =~ s/_/ /g;
            $dt = DateTime::Format::DateParse->parse_datetime($dt);
            return undef unless($dt);
        }
    }
    $dt = $dt->ymd().'T'.$dt->hms().'Z';
    return $dt;
}

=back
=cut


1;
__END__

=head1 SEE ALSO

 CIF::Archive
 http://code.google.com/p/collective-intelligence-framework/

=head1 AUTHOR

Wes Young, E<lt>wes@barely3am.comE<gt>

=head1 COPYRIGHT AND LICENSE

 Copyright (C) 2011 by Wes Young (claimid.com/wesyoung)
 Copyright (C) 2011 by the Trustee's of Indiana University (www.iu.edu)
 Copyright (C) 2011 by the REN-ISAC (www.ren-isac.net)

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
