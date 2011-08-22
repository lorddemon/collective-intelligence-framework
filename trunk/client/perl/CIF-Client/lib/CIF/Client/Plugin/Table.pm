package CIF::Client::Plugin::Table;
use base 'CIF::Client::Plugin::Output';

use Text::Table;

sub write_out {
    my $self = shift;
    my $config = shift;
    my $feed = shift;
    my $summary = shift;

    my $query = $feed->{'query'};
    my $hash = $feed->{'feed'};
    my $created = $hash->{'created'} || $hash->{'detecttime'};
    my $feedid = $hash->{'id'};
    my @a = @{$hash->{'entry'}};
    return unless(keys(%{$a[0]}));
    my @cols;
    if($::uuid){
        push(@cols,'uuid');
    }
    if($::relateduuid){
        push(@cols,'relatedid');
    }
    push(@cols,(
        'restriction',
        'severity',
        'confidence',
        'detecttime',
    ));
    unless($summary){
        my $t = $a[0];
        if(exists($t->{'address'})){
            push(@cols,('address'));
        }
        if(exists($t->{'protocol'})){
            push(@cols,'protocol');
        }
        if(exists($t->{'portlist'})){
            push(@cols,'portlist');
        }
        if(exists($t->{'rdata'})) {
            push(@cols,('rdata','type'));
        } 
        if(exists($t->{'asn'})) {
            push(@cols,'asn','prefix');
        } 
        if(exists($t->{'rir'})){
            push(@cols,'rir');
        }
        if(exists($t->{'md5'})){
            push(@cols,('md5','sha1'));
        } 
        if(exists($t->{'cc'})){
            push(@cols,'cc');
        }
    }
    unless($a[0]->{'count'}){
        push(@cols,(
            'impact',
            'description',
            'alternativeid_restriction',
            'alternativeid',
        ));
   }
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
    if($config->{'description'}){
        $table = 'Description: '.$config->{'description'}."\n".$table;
    }
    $table = "Query: ".$query."\n".$table;
    return "\n".$table;
}

1;
