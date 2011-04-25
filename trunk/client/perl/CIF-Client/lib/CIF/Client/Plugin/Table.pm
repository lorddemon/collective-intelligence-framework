package CIF::Client::Plugin::Table;

use Text::Table;

sub write_out {
    my $self = shift;
    my $config = shift;
    my $feed = shift;

    my $hash = $feed->{'feed'};
    my $created = $hash->{'created'} || $hash->{'detecttime'};
    my $feedid = $hash->{'id'};
    my @a = @{$hash->{'entry'}};
    my @cols = (
        'restriction',
        'severity',
    );
    if(exists($a[0]->{'hash_md5'})){
        push(@cols,('hash_md5','hash_sha1'));
    } elsif(exists($a[0]->{'url_md5'})){
        push(@cols,('address','url_md5','url_sha1','malware_md5','malware_sha1'));
    } elsif(exists($a[0]->{'rdata'})) {
        push(@cols,('address','rdata','type'));
    } elsif($a[0]->{'asn'} && !$a[0]->{'address'}) {
        push(@cols,'asn','asn_desc','cc');
    } else {
        push(@cols,'address','portlist');
    }
    push(@cols,(
        'detecttime',
        'description',
        'alternativeid_restriction',
        'alternativeid',
    ));
    if($self->{'fields'}){
        @cols = @{$self->{'fields'}};
    }
    if(my $c = $self->{'config'}->{'display'}){
        @cols = @$c;
    }

    my @header = map { $_, { is_sep => 1, title => '|' } } @cols;
    pop(@header);
    my $table = Text::Table->new(@header);

    my @sorted = sort { $a->{'detecttime'} cmp $b->{'detecttime'} } @a;
    if(my $max = $self->{'max_desc'}){
        map { $_->{'description'} = substr($_->{'description'},0,$max) } @sorted;
    }
    foreach my $r (@sorted){
        $table->load([ map { $r->{$_} } @cols]);
    }
    if($created){
        $table = "Feed Created: ".$created."\n\n".$table;
    }
    if(my $r = $hash->{'restriction'}){
        $table = "Feed Restriction: ".$r."\n".$table;
    }
    if(my $s = $hash->{'severity'}){
        $table = 'Feed Severity: '.$s."\n".$table;
    }
    if($feedid){
        $table = 'Feed Id: '.$feedid."\n".$table;
    }
    return "\n".$table;
}

1;
