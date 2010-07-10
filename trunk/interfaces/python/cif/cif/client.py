from restclient import GET
import re
import simplejson as json
from texttable import Texttable

class Client:
    def apikey(self,v=None):
        if v:
            self._apikey = v
        return self._apikey

    def url(self,v=None):
        if v:
            self._url = v 
        return self._url

    def format(self,v=None):
        if v:
            self._format = v
        return self._format

    def search(self,q,fmt='json'):
        if self.format():
            fmt = self.format()
        p_address   = re.compile('^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')
        p_asn       = re.compile('^\d+$')
        p_email     = re.compile('\w+@\w+')
        p_domain    = re.compile('\w+\.\w+')
        p_malware   = re.compile('^[a-fA-F0-9]{32,40}$')
        p_url       = re.compile('^url:([a-fA-F0-9]{32,40})$')
        p_impact    = re.compile('^\S+$')

        search_type = {
            1 == 1                      : 'unknown',
            p_impact.match(q)   != None : 'impact',
            p_url.match(q)      != None : 'url',
            p_malware.match(q)  != None : 'malware',
            p_domain.match(q)   != None : 'domain',
            p_email.match(q)    != None : 'email',
            p_asn.match(q)      != None : 'asn',
            p_address.match(q)  != None : 'inet'
        } [1]

        if (search_type == 'url'):
            m = p_url.match(q)
            q = m.group(1)

        s = self._url + '/search/' + search_type + '/' + q
        return GET(s, params={'apikey':self._apikey, 'format':fmt})

    def table(self,j):
        j = json.loads(j)
        t = Texttable(max_width=255)
        cols = ['restriction','impact','description','detecttime','reference']
        if j[0].get('address'):
            cols.append('address')
        t.add_row(cols)
        for key in j:
            cs = [key['restriction'],key['impact'],key['description'],key['detecttime'],key['reference']]
            if key.get('address'):
                cs.append(key['address'])
            t.add_row(cs)
        return t.draw()

