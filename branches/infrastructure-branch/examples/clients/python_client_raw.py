#!/usr/bin/python

from restclient import GET
import re
import simplejson as json 
from texttable import Texttable
import sys
import os
import getopt

_debug = 0

def search(q,fmt):
    p_address = re.compile('^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')
    p_asn = re.compile('^\d+$')
    p_email = re.compile('\w+@\w+')
    p_domain = re.compile('\w+\.\w+')
    p_malware = re.compile('^[a-fA-F0-9]{32,40}$')

    search_type = {
        1 == 1 : 'unknown',
        p_malware.match(q) != None : 'malware',
        p_domain.match(q) != None : 'domain',
        p_email.match(q) != None : 'email',
        p_asn.match(q) != None : 'asn',
        p_address.match(q) != None : 'inet'
    } [1]
    
    str = URL + '/search/' + search_type + '/' + q 
    if _debug:
        print "DEBUG: REST URL: " + URL

    return GET(str, params={'apikey':APIKEY, 'format':fmt})

def usage():
    print """Usage: python """ + sys.argv[0] + """ -q xyz.com -f table
        -h  --help:                 this message
        -d  --debug:                debug output
        -f  --format [raw|table]:   output format
        -q <string>:                query string

    configuration file ~/.cif should be readable and look something like:
    
    url=https://example.com:443/REST/1.0/cif
    apikey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

"""

def main(argv):
    format = 'json'
    query = ''
    try:
        opts, args = getopt.getopt(argv,"dhf:q:",["debug","help","format=","query="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt,arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit()
        elif opt == '-f':
            format = arg
            if format not in ("raw","table"):
                usage()
                sys.exit()
            format = 'json'
            if arg == 'raw':
                format = 'text'
        elif opt == '-q':
            query = arg
        elif opt == '-d':
            _debug = 1;

    if not query:
        usage()
        sys.exit()

    r = search(query,format)
    array = r.split('\n')
        
    p_status = re.compile('^RT.* 200 Ok (\d+)\/\d+.*$')
    m = p_status.match(array[0])

    if (int(m.group(1)) > 0):
        if format == 'text':
            for a in array:
                print a
            sys.exit()

        j = json.loads(array[2])
        t = Texttable(max_width=255)
        t.add_row(['restriction','impact','description','detecttime','reference'])
        for key in j:
            t.add_row([key['restriction'],key['impact'],key['description'],key['detecttime'],key['reference']])

        print t.draw()


try:
    config = open('%s/.cif' % os.getenv('HOME'), 'r').read().split('\n')
except:
    print '**unable to read ~/.cif config file**\n'
    usage()
    sys.exit()

for c in config:
    c1 = c.split('=')
    if c1[0] == 'url':
        URL = c1[1]
    if c1[0] == 'apikey':
        APIKEY = c1[1]

if __name__ == "__main__":
    main(sys.argv[1:])
