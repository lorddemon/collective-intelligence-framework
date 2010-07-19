#!/usr/bin/python

import sys
import re
import os
import getopt
from cif.client import ClientINI

def usage():
    print """Usage: python """ + sys.argv[0] + """ -q xyz.com -f table
        -h  --help:                 this message
        -d  --debug:                debug output
        -f  --format [raw|table]:   output format
        -q <string>:                query string

    configuration file ~/.cif should be readable and look something like:
    
    [client]
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

    do_search(query, format)

def do_search(query, format):
    rclient = ClientINI()
    rclient.format = format
    r = rclient.search(query)
    array = r.split('\n')
        
    #this stuff belongs in the client
    p_status = re.compile('^RT.* 200 Ok (\d+)\/\d+.*$')
    m = p_status.match(array[0])

    if (int(m.group(1)) > 0):
        if format == 'text':
            for a in array:
                print a
        else:
            print rclient.table(array[2])


if __name__ == "__main__":
    main(sys.argv[1:])
