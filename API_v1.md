# Introduction #


## Overview ##
The CIF API is the programming interface to the CIF architecture. This can be used to integrate CIF data into day to day operational applications.

CIF currently supports two styles of interfaces via the cif-router framework:

  * google [protocol buffers](https://developers.google.com/protocol-buffers/docs/overview)
  * legacy access via raw HTTP GET/POST

## Repositories ##
The v1 cif repositories can be found on github:
  * top-level v1 meta [repo](https://github.com/collectiveintel/cif-v1)
  * libcif v1 [repo](https://github.com/collectiveintel/libcif/tree/v1)
  * simple python [client](https://github.com/collectiveintel/cif-client-python/tree/v1)
  * libcif-dbi v1 [repo](https://github.com/collectiveintel/libcif-dbi/tree/v1)
  * cif-smrt v1 [repo](https://github.com/collectiveintel/cif-smrt/tree/v1)
  * cif-router v1 [repo](https://github.com/collectiveintel/cif-router/tree/v1)

# Details #
## Protocol Buffers ##
The raw cif-protocol is implemented in [libcif](https://github.com/collectiveintel/libcif/tree/v1) that can be leveraged by applications with-out requiring the application to understand the underlying protocol. The 'cif' [command](https://github.com/collectiveintel/libcif/blob/v1/bin/cif) serves as an example of how to interact with the underlying libraries.

## HTTP ##
The interface also supports (legacy) use of the [HTTP protocol](https://code.google.com/p/collective-intelligence-framework/wiki/API_HTTP_v1). The cif-router acts as a proxy for applications where leveraging google protocol buffers is not an efficient option. The router will translate between the JSON based HTTP GET requests to the cif-protocol and vs versa.

# Considerations #
## Compression ##
In most cases, anything represented as "data" in the protocol is base64-compressed (base64+snappy) using google's [snappy](http://code.google.com/p/snappy) compression protocol. libcif takes care of the decode+decompression for applications, however if you're implementing the protocol manually or in another language, this should be taken into consideration.

## IODEF ##
The data returned by the [FeedType](API_CIFProtocol_v1#FeedType.md) within cif-protocol in v1 is structured as [IODEF](http://tools.ietf.org/html/rfc5070) (RFC5070). libcif leverages another library, [iodef-pb-simple-perl](https://github.com/collectiveintel/iodef-pb-simple-perl) to convert the IODEF structures to simple key-pair values.

In v1, to leverage in another language, it might be simpler to leverage the 'cif' command to output these more complex structures into the simple key-pair values, encoded in json for manipulation in an (lets say python) application:

```
# example adapted from: 
# https://github.com/technoskald/maltegoxforms/blob/master/cif-maltego.py
import sys
import json
import pprint

pp = pprint.PrettyPrinter(indent=4)

from subprocess import Popen, PIPE

cifresult = Popen('libcif/bin/cif -n -q example.com -p json', shell=True, stdout=PIPE).stdout.read()
#sys.stderr.write(cifresult+'\n')



array = cifresult.split('\n')
for result in array:
    if result:
        r = json.loads(result)
        sys.stderr.write(r['description']+',')
        sys.stderr.write(r['address']+',')
        sys.stderr.write(r['reporttime']+',')
        sys.stderr.write(r['assessment']+'\n')
```

with the release of v2, libcif should be completed in C and able to be bound to many lower level languages natively.