from restclient import GET
import simplejson as json
from texttable import Texttable
import os
import ConfigParser
import magic
from base64 import b64decode
import re
import cStringIO
import hashlib
import zlib

version = '0.00_04'

import pprint
pp = pprint.PrettyPrinter(indent=4)
class Client(object):
    def __init__(self, **vars):
        self.host = vars['host']
        self.apikey = vars['apikey']

        if vars.get('fields'):
            assert isinstance(vars['fields'],list)
            self.fields = vars['fields']

    def set_fields(self, **vars):
        assert isinstance(vars['fields'],list)
        self.fields = vars['fields']
        
    def GET(self,q,severity=None,restriction=None):
        s = self.host + '/' + q
        
        params={'apikey':self.apikey}
        if restriction:
            params['restriction'] = restriction
        if severity:
            params['severity'] = severity

        ret = GET(s, params)
        ret = json.loads(ret)
        self.responseCode = ret['status']

        if ret['data'].get('result') and ret['data']['result'].get('hash_sha1'):
            hash = hashlib.sha1()
            feed = ret['data']['result']['feed']
            hash.update(feed)
            if hash.hexdigest() != ret['data']['result']['hash_sha1']:
                print "sha1's don't match, possible data corruption... try re-downloading"
                return

            feed = zlib.decompress(b64decode(feed))
            ret['data']['result']['feed'] = json.loads(feed)
        
        self.responseContent = json.dumps(ret)

    def table(self,j):
        j = json.loads(j)
        if not j['data'].get('result'): 
            return 0

        j = j['data']['result']
        
        created = None
        restriction = None
        severity = None
        feedid = None

        if j.get('created'):
            created = j.get('created') 
       
        if j['feed'].get('restriction'):
            restriction = j['feed'].get('restriction')

        if j['feed'].get('severity'):
            severity = j['feed'].get('severity')

        if j.get('id'):
            feedid = j.get('id')

        feed = j['feed']['items']
        
        t = Texttable(max_width=0)
        t.set_deco(Texttable.VLINES)

        if hasattr(self,'fields'):
            cols = self.fields
        else:
            cols = ['restriction','severity']
            if feed[0].get('address'):
                cols.append('address')
                if feed[0].get('rdata'):
                    cols.extend(['rdata','type'])
            if feed[0].get('hash_md5'):
                cols.extend(['hash_md5','hash_sha1'])
            cols.extend(['detecttime','description','alternativeid_restriction','alternativeid'])
        
        t.add_row(cols)
        for key in feed:
            row = []
            for col in cols:
                row.append(key[col])
            t.add_row(row)

        table = t.draw()
        
        if created:
            table = 'Feed Created: ' + created + "\n\n" + table

        if restriction:
            table = 'Feed Restriction: ' + restriction + "\n" + table

        if severity:
            table = 'Feed Severity: ' + severity + "\n" + table

        if feedid:
            table = 'Feed Id: ' + feedid + "\n" + table

        return table

class ClientINI(Client):
    def __init__(self, path=None, fields=None):
        if not path:
            path = os.path.expanduser("~/.cif")
        c = ConfigParser.ConfigParser()
        c.read([path])
        if not c.has_section('client'):
            raise Exception("Unable to read ~/.cif config file")
        vars = dict(c.items("client"))
        if fields:
            vars['fields'] = fields
        Client.__init__(self, **vars)
