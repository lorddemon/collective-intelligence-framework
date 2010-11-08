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
        -q <string>:                query string

    configuration file ~/.cif should be readable and look something like:
    
    [client]
    url=https://example.com:443/api
    apikey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

"""

def main(argv):
    query = ''
    try:
        opts, args = getopt.getopt(argv,"dhf:q:",["debug","help","query="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt,arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit()
        elif opt == '-f':
            format = arg
        elif opt == '-q':
            query = arg
        elif opt == '-d':
            _debug = 1;

    if not query:
        usage()
        sys.exit()

    do_search(query)

def do_search(query):
    rclient = ClientINI()
    r = rclient.search(query)
    
    print rclient.table(r)

if __name__ == "__main__":
    main(sys.argv[1:])
