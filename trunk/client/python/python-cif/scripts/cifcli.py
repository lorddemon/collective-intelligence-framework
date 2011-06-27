#!/usr/bin/python

import cif
import argparse
import os

if __name__ == '__main__':
    # Parse Command Line Arguments
    parser = argparse.ArgumentParser(description="Command line interface to CIF APIs")

    parser.add_argument("-q",'--query', nargs='*',metavar="QUERY")
    parser.add_argument('-s','--severity',help="specify the default severity")
    parser.add_argument('-r','--restriction')
    parser.add_argument("-f", '--fields',nargs='*',metavar="FIELD")
    parser.add_argument("-c","--config",default=os.path.expanduser("~/.cif"))
    parser.add_argument("-n","--nolog",action="store_true",default=False,help="do not log the query on the server")
    args = parser.parse_args()
    print args

    if not args.query:
        parser.print_help()
        print "\n"
        print "example: python cifcli.py -q infrastructure/botnet -f restriction address asn cidr\n"
        print "example, without the query being logged:\n"
        print "python cifcli.py -q 1.2.3.4 -n\n"
        os._exit(-1)        

    rclient = cif.ClientINI(path=args.config,fields=args.fields,nolog=args.nolog)

    for query in args.query:
        # this returns a dict
        # need to translate it to an object with "plugin" type properties
        feed = rclient.GET(query,args.severity,args.restriction,args.nolog)
        if rclient.responseCode != 200:
            print 'request failed with code: ' + str(rclient.responseCode)
            os._exit(-1)

        print "Query: " + query
        text = rclient.table(feed)
        print text
