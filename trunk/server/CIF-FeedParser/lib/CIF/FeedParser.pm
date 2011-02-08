package CIF::FeedParser;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.00_01';
$VERSION = eval $VERSION;  # see L<perlmodstyle>

use LWP::Simple;
use DateTime::Format::DateParse;
use DateTime;
use XML::RSS;
use CIF::Message::DomainSimple;
use CIF::Message::InfrastructureSimple;
use CIF::Message::UrlSimple;
use CIF::Message::Malware;
use CIF::Message::Email;
use Regexp::Common qw/net/;
use Encode qw/encode_utf8/;
use Data::Dumper;
use File::Type;
use Compress::Zlib;
use JSON;

# Preloaded methods go here.

sub parse {
    my $f = shift;
    my $content;
    for($f->{'feed'}){
        if(/^file\:\/\/(\S+)/){
            open(F,$1) || die($!);
            my @lines = <F>;
            close(F);
            $content = join('',@lines);
        } else {
            $content = get($f->{'feed'}) || die($!);
        }
    }
    $content = _decode($content);
    
    $content = encode_utf8($content);
    
    if($content =~ /<\?xml version="\S+"/){
        if($content =~ /<rss version=/){
            return _parse_rss($f,$content);
        } else {
            return _parse_xml($f,$content);
        }
    } elsif($content =~ /^{?\[/){
        # possible json content
        return _parse_json($f,$content);
    } else {
        return _parse_txt($f,$content);
   }
}

sub _decode {
    my $data = shift;

    my $ft = File::Type->new();
    my $t = $ft->mime_type($data);
    for($t){
        if(/gzip/){
           return _decode_gzip($data);
        }
        return $data;
    }
}

sub _decode_gzip {
    my $data = shift;
    return Compress::Zlib::memGunzip($data) || die('failed to decompress');
}

sub _parse_json {
    my $f = shift;
    my $content = shift;

    my @feed = @{from_json($content)};
    my @fields = split(',',$f->{'fields'});
    my @fields_map = split(',',$f->{'fields_map'});
    my @array;
    foreach my $a (@feed){
        foreach (0 ... $#fields_map){
            $a->{$fields_map[$_]} = lc($a->{$fields[$_]});
        }
        map { $a->{$_} = $f->{$_} } keys %$f;
        push(@array,$a);
    }
    return(@array);
}

sub _parse_xml {
    my $f = shift;
    my $content = shift;
    
    my $parser = XML::LibXML->new();
    my $doc = $parser->load_xml(string => $content);
    my @nodes = $doc->findnodes('//'.$f->{'node'});
    return unless(@nodes);
    my @array;
    my @elements = split(',',$f->{'elements'});
    my @elements_map = split(',',$f->{'elements_map'});
    foreach my $node (@nodes){
        my $h;
        foreach (0 ... $#elements_map){
            $h->{$elements_map[$_]} = $node->findvalue('./'.$elements[$_]);
        }
        map { $h->{$_} = $f->{$_} } keys %$f;
        push(@array,$h);   
    }
    return(@array);
}

sub _parse_rss {
    my $f = shift;
    my $content = shift;
    my $rss = XML::RSS->new();
    $rss->parse($content);
    my @array;
    foreach my $item (@{$rss->{items}}){
        my $h;
        foreach my $key (keys %$item){
            if(my $r = $f->{'regex_'.$key}){
                my @m = ($item->{$key} =~ /$r/);
                my @cols = split(',',$f->{'regex_'.$key.'_values'});
                foreach (0 ... $#cols){
                    $h->{$cols[$_]} = $m[$_];
                }
            }
        }
        map { $h->{$_} = $f->{$_} } keys %$f;
        push(@array,$h);
    }
    return(@array);
}

sub _parse_txt {
    my $f = shift;
    my $content = shift;
    my @lines = split(/\n/,$content);
    my @array;
    foreach(@lines){
        next if(/^(#|$)/);
        my @m = ($_ =~ /$f->{'regex'}/);
        next unless(@m);
        my $h;
        my @cols = split(',',$f->{'regex_values'});
        foreach (0 ... $#cols){
            $h->{$cols[$_]} = $m[$_];
        }
        map { $h->{$_} = $f->{$_} } keys %$f;
        push(@array,$h);
    }
    return(@array);
}



sub insert {
    my ($full,@recs) = (shift,@_);
    my $goback = DateTime->from_epoch(epoch => (time() - (84600 * 5)));
    $goback = $goback->ymd().'T'.$goback->hms().'Z';

    foreach (@recs){
        delete($_->{'regex'});
        my $dt = $_->{'detecttime'};
        unless($dt){
            $dt = DateTime->from_epoch(epoch => time());
            if(lc($_->{'detection'}) eq 'hourly'){
                $dt = $dt->ymd().'T'.$dt->hour.':00:00Z';
            } else {
                $dt = $dt->ymd().'T00:00:00Z';
            }
            $_->{'detecttime'} = $dt;
        }
        $_->{'description'} = '' unless($_->{'description'});
        $_->{'detecttime'} = normalize_date($_->{'detecttime'});
        foreach my $key (keys %$_){
            next unless($_->{$key});
            if($_->{$key} =~ /<(\S+)>/){
                my $x = $_->{$1};
                $_->{$key} =~ s/<\S+>/$x/;
            }
        }
    }

    @recs = sort { $b->{'detecttime'} cmp $a->{'detecttime'} } @recs;
    foreach(@recs){
        unless($full){
            next if(($_->{'detecttime'} cmp $goback) == -1);
        }
        _insert($_);
    }
}

sub _insert {
    my $f = shift;
    my $a = $f->{'hash_md5'} || $f->{'address'};
    return unless($a && length($a) > 2);
    if($f->{'description'}){
        $f->{'description'} = $f->{'impact'}.' '.$f->{'description'}.' '.$a;
    } else {
        $f->{'description'} = $f->{'impact'}.' '.$a;
    }

    my $bucket = 'CIF::Message::';
    for($a){
        if(/^([A-Za-z0-9.-]+\.[a-zA-Z]{2,6})$/ && ($f->{'impact'} !~ / url/)){
            $bucket .= 'DomainSimple';
            last;
        }
        if(/^$RE{'net'}{'IPv4'}/){
            $bucket .= 'InfrastructureSimple';
            last;
        }
        if(/^[a-fA-F0-9]{32,40}$/){
            $bucket .= 'Malware';
            last;
        }
        if(/[\w]+@[\w]+/){
            $bucket .= 'Email';
            last;
        } else {
            $bucket .= 'UrlSimple';
        }
    }
    my $id = $bucket->insert({ %{$f} });
    my $rid = ($id =~ /^\d+$/) ? $id->uuid() : $id;
    print $f->{'source'}.' -- '.$a.' -- '.$id->description().' -- '.$id->detecttime().' -- '.$rid."\n";
}

sub normalize_date {
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
            $dt = DateTime::Format::DateParse->parse_datetime($dt);
            return undef unless($dt);
        }
    }
    $dt = $dt->ymd().'T'.$dt->hms().'Z';
    return $dt;
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

CIF::FeedParser - Perl extension for blah blah blah

=head1 SYNOPSIS

  use CIF::FeedParser;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for CIF::FeedParser, created by h2xs. It looks like the
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

Copyright (C) 2011 by Wes Young

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.


=cut
