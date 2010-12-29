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
import gzip

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
        feed = ret['data']['result']
        hash = hashlib.sha1()
        hash.update(feed)
        if hash.hexdigest() != ret['data']['hash_sha1']:
            print "sha1's don't match, possible data corruption... try again"
            return

        feed = b64decode(feed)
        m = magic.Magic()
        mime = m.from_buffer(feed)
        if re.search('gzip',mime):
            compressedstream = cStringIO.StringIO(feed)
            gzipper = gzip.GzipFile(fileobj=compressedstream)
            feed = gzipper.read()
            ret['data']['result'] = json.loads(feed)
            ret = json.dumps(ret)

        return ret

    def table(self,j):
        j = json.loads(j)
        if not j['data'].get('result'): 
            return 0

        if j['data'].get('created'):
            created = j['data'].get('created') 
        
        j = j['data']['result']

        t = Texttable(max_width=0)
        t.set_deco(Texttable.VLINES)

        if hasattr(self,'fields'):
            cols = self.fields
        else:
            cols = ['restriction','severity']
            if j[0].get('address'):
                cols.append('address')
            cols.extend(['detecttime','description','alternativeid_restriction','alternativeid'])
        
        t.add_row(cols)
        for key in j:
            row = []
            for col in cols:
                row.append(key[col])
            t.add_row(row)

        table = t.draw()
        
        if created:
            table = 'feed created: ' + created + "\n\n" + table

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
