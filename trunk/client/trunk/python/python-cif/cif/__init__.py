from restclient import GET
import simplejson as json
from texttable import Texttable
import os
import ConfigParser
from base64 import b64decode
import hashlib
import zlib
import pprint
pp = pprint.PrettyPrinter(indent=4)

version = '0.00_04'

class Client(object):
    def __init__(self, host, apikey, fields=None, severity=None, restriction=None):
        self.host = host
        self.apikey = apikey

        self._fields = fields
        """ override order: passed args, config file args """
        self.severity = severity
        self.restriction = restriction

    def _get_fields(self):
        return self._fields
        
    def _set_fields(self, fields):
        if fields:
            assert isinstance(fields, list)
        self._fields = fields
    fields = property(_get_fields, _set_fields)
    
    def GET(self,q,severity=None,restriction=None):
        s = self.host + '/' + q
        
        params={'apikey':self.apikey}

        if restriction:
            params['restriction'] = restriction
        elif self.restriction:
            params['restriction'] = self.restriction

        if severity:
            params['severity'] = severity
        elif self.severity:
            params['severity'] = self.severity

        ret = GET(s, params)
        ret = json.loads(ret)

        """ we're mirroring the perl client lib here """
        self.responseCode = ret['status']

        """ check to see if we've got a feed object, auto-de(code/compress) it """
        if ret['data'].get('result') and ret['data']['result'].get('hash_sha1'):
            hash = hashlib.sha1()
            feed = ret['data']['result']['feed']
            hash.update(feed)
            if hash.hexdigest() != ret['data']['result']['hash_sha1']:
                print "sha1's don't match, possible data corruption... try re-downloading"
                return

            feed = zlib.decompress(b64decode(feed))
            ret['data']['result']['feed'] = json.loads(feed)
        
        """ again, mirroring the perl module with responseContent() """
        self.responseContent = json.dumps(ret)

    def table(self,j):
        """
        Take in the JSON object and print a neat table out of the data

        Keyword args:
        self -- self
        j -- json data
        """
        j = json.loads(j)
        if not j['data'].get('result'): 
            return 0

        j = j['data']['result']
        
        created = j.get('created') 
        feedid = j.get('id')
        restriction = j['feed'].get('restriction')
        severity = j['feed'].get('severity')

        feed = j['feed']['items']
        
        t = Texttable(max_width=0)
        t.set_deco(Texttable.VLINES)

        if self.fields:
            cols = self.fields
        else:
            cols = ['restriction','severity']
            if feed[0].get('rdata'):
                cols.extend(['address','rdata','type'])
            elif feed[0].get('hash_md5'):
                cols.extend(['hash_md5','hash_sha1'])
            else:
                cols.extend(['address','portlist'])

            cols.extend(['detecttime','description','alternativeid_restriction','alternativeid'])
        
        t.add_row(cols)
        for item in feed:
            t.add_row([item[col] or '' for col in cols])
            
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
    def __init__(self, path=None, fields=None, severity=None, restriction=None):
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
