# Introduction #


Interacting via protocol buffers requires that the actual data is encoded properly for the 'API' to process the data appropriately. Instead of passing required parameters to a 'live' API as with the [HTTP](API_HTTP_v1.md) interface, we generate the appropriate data structure locally and pass along to the transport layer (HTTP, ZeroMQ, etc) as a data-blob and wait for a response.

An example implementation can be found via the [libcif](https://raw.github.com/collectiveintel/libcif/v1/lib/CIF/Client.pm) client.

# Details #
## Common Parameters ##

| Parameter Name | Value | Description |
|:---------------|:------|:------------|
| apikey         | 

&lt;uuid&gt;

 | specify your apikey |
| confidence     | 

&lt;real&gt;

 | filter by confidence, **0-100** |
| restriction    | 

&lt;enum&gt;

 | filter by restriction, **public,need-to-know,private** |
| guid           | 

&lt;uuid&gt;

 | filter by group uuid |
| nomap          | 

&lt;boolean&gt;

 | don't map restriction to your local restriction map |
| nolog          | 

&lt;boolean&gt;

 | don't log the query |

## Config ##
Interacting with this API requires instantiating 'CIF::Client' objects. This is done by calling the ->new() creator:
```
use CIF::Client;
my $cli = CIF::Client->new();
```
To leverage an existing config file with the 'host' and 'apikey' information:
```
my $cli = CIF::Client->new({
    config => '/home/cif/.cif',
});
```
## Authorization ##
This API uses a simple uuid for it's authorization. This key is passed to the api using the 'apikey' parameter:

```
my ($err,$ret) = CIF::Client->new({
    apikey => '249cd5fd-04e3-46ad-bf0f-c02030cc864a'
});
```

or set at run-time:
```
$cli->set_apikey('249cd5fd-04e3-46ad-bf0f-c02030cc864a');
```
## Queries ##
The 'search' function is used to facilitate queries:
```
my ($err,$ret) = $cli->search({
    query               => 'example.com',
    confidence          => $confidence,
});
```
## Submissions ##
### Easy ###
Beginning in RC5 (or v1-final), there is a simple way to submit simple keypairs to the cif-router using libcif. The underlying library will generate the Iodef messages automatically and send them to the router.
```
#!/usr/bin/perl -w

use CIF::Client;

my ($err,$cli) = CIF::Client->new({
    config          => $ENV{'HOME'}.'/.cif',
});

if($err){
    print 'ERROR: '.$err."\n";
    exit(-1);
}

my $keypair = {
    address     => 'example.com',
    assessment  => 'botnet',
    confidence  => 85,
    description => 'zeus',
    guid        => 'everyone',
};

my $ret = $cli->send_keypairs({ data => $keypair });
die ::Dumper($ret);
```

The return:
```
$VAR1 = bless( {
                 'status' => 1,
                 'version' => '0.9905',
                 'data' => [
                             '506d28d0-bf49-4420-9ce8-138344095a1f'
                           ],
                 'type' => 3
               }, 'MessageType' );
```
### Advanced ###
Advanced submissions are currently a two-step process and require some knowledge of how [iodef-pb-simple-perl](https://github.com/collectiveintel/iodef-pb-simple-perl) works. More complex examples exist within [cif-smrt](https://github.com/collectiveintel/cif-smrt/tree/v1).# this adapted from cif-smrt v1
use CIF;
use CIF::Client;
use Iodef::Pb::Simple;

# create a client object
my ($err,$ret) = CIF::Config->new({
    config => '/home/cif/.cif',
});

my $cli = $ret;

# my data
my $hash = {
    address     => 'example.com',
    assessment  => 'botnet',
    confidence  => 86,
    description => 'zeus',
};

# generate an IODEF object from the key-pair
# https://github.com/collectiveintel/cif-smrt/blob/v1/lib/CIF/Smrt.pm#L571
my $iodef = Iodef::Pb::Simple->new($hash);

# generate a new SubmssionType cif-protocol object
# https://github.com/collectiveintel/cif-smrt/blob/v1/lib/CIF/Smrt.pm#L726
$ret = $cli->new_submission({
    guid    => 'everyone',
    data    => $iodef->encode(),
});
    
$ret = $cli->submit($ret);```