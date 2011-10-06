#!/usr/bin/python

import cif
import argparse
import os
import pprint
pp = pprint.PrettyPrinter(indent=4)

if __name__ == '__main__':
    # Parse Command Line Arguments
    parser = argparse.ArgumentParser(description="Command line interface to CIF APIs")

    parser.add_argument('-s','--severity',help="specify the default severity")
    parser.add_argument('-c','--confidence',help="specify the default confidence")
    parser.add_argument('-r','--restriction',help='specify the default restriction')
    parser.add_argument("-C","--config",default=os.path.expanduser("~/.cif"))
    parser.add_argument("-T","--no_verify_tls",default=False,action="store_true")
    args = parser.parse_args()

    rclient = cif.ClientINI(path=args.config,fields=None,no_verify_tls=args.no_verify_tls)
    data = {}
    data['impact'] = 'botnet'
    data['description'] = 'unknown'
    data['severity'] = 'high'
    data['confidence'] = 50
    data['address'] = 'example.com'
    data['guid'] = 'everyone'
    
    ret = rclient.POST(data)
    pp.pprint(ret)

