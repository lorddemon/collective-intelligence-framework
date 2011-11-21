package CIF::WebAPI::Writer::chart;

use JSON;
use MIME::Base64;
use Compress::Zlib;
require CIF::Client;

=head1 NAME

Apache2::REST::Writer::table - Apache2::REST::Response Writer for Text::Table

=cut

=head2 new

=cut

sub new{
    my ( $class ) = @_;
    return bless {} , $class;
}

=head2 mimeType

Getter

=cut

sub mimeType {
    return 'text/html';
}

=head2 asBytes

Returns the response as json UTF8 bytes for output.

=cut

sub asBytes{
    my ($self,  $resp ) = @_ ;

    return $resp->{'message'} if($resp->{'message'});
    return 'no records, check back later' unless($resp->{'data'});
    my $hash = $resp;
    require CIF::Client;

    my $t = ref(@{$hash->{'data'}->{'feed'}->{'entry'}}[0]) || '';
    unless($t eq 'HASH'){
        my $r = @{$hash->{'data'}->{'feed'}->{'entry'}}[0];
        return unless($r);
        $r = uncompress(decode_base64($r));
        $r = from_json($r);
        $hash->{'data'}->{'feed'}->{'entry'} = $r;
    }
    if(1 || $args{'conf'}->{'simple'}){
        CIF::Client->hash_simple($hash);
    }
    use Data::Dumper;
    warn Dumper($hash);

    my @entries;
    @entries = @{$hash->{'data'}->{'feed'}->{'entry'}};
    my @array;
    my $hash = {};
    foreach my $e (@entries){
        my $impact = $e->{'impact'};
        if($hash->{$impact}){
            $hash->{$impact}++;
        } else {
            $hash->{$impact} = 1;
        }
    }
    my @array;
    foreach my $e (keys %$hash){
        push(@array,[$e,$hash->{$e}]);
    }
    my $json = JSON::to_json(\@array);

    return <<EOF;
  <head>
    <!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">
    
      // Load the Visualization API and the piechart package.
      google.load('visualization', '1', {'packages':['corechart']});
      
      // Set a callback to run when the Google Visualization API is loaded.
      google.setOnLoadCallback(drawChart);
      
      // Callback that creates and populates a data table, 
      // instantiates the pie chart, passes in the data and
      // draws it.
      function drawChart() {

      // Create our data table.
      var data = new google.visualization.DataTable();
      data.addColumn('string', 'Impact');
      data.addColumn('number', 'Count');
      data.addRows($json);

      // Instantiate and draw our chart, passing in some options.
      var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
      chart.draw(data, {width: 800, height: 480});
    }
    </script>
  </head>

  <body>
    <!--Div that will hold the pie chart-->
    <div id="chart_div"></div>
  </body>

EOF
}

1;
