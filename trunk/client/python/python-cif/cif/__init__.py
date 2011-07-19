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

class Client(object):
    def __init__(self, host, apikey, fields=None, severity=None, restriction=None, nolog=None, **args):
        self.host = host
        self.apikey = apikey

        self._fields = fields
        """ override order: passed args, config file args """
        self.severity = severity
        self.restriction = restriction
        self.nolog = nolog

    def _get_fields(self):
        return self._fields
        
    def _set_fields(self, fields):
        if fields:
            assert isinstance(fields, list)
        self._fields = fields
    fields = property(_get_fields, _set_fields)
    
    def GET(self,q,severity=None,restriction=None,nolog=None,confidence=None):
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

        if confidence:
            params['confidence'] = confidence
        elif self.confidence:
            params['confidence'] = self.confidence

        if nolog:
            params['nolog'] = 1
        elif self.nolog:
            params['nolog'] = 1

        ret = GET(s, params)
        ret = json.loads(ret)

        """ we're mirroring the perl client lib here """
        self.responseCode = ret['status']

        """ check to see if we've got a feed object, auto-de(code/compress) it """
        feed = ret['data']

        if not feed.get('feed'):
            return

        entry = feed['feed']['entry']
        if type(entry[0]) == str:
            jstring = zlib.decompress(b64decode(entry[0]))
            entry = json.loads(jstring)
            feed['feed']['entry'] = entry

        #""" again, mirroring the perl module with responseContent() """
        #self.responseContent = json.dumps(ret)
        return feed

    def simple(self,incident):
            ret = {}
            impact = incident['Assessment']['Impact']
            ret['restriction'] = incident['restriction']
            ret['purpose'] = incident['purpose']
            ret['detecttime'] = incident['DetectTime']
            if(incident['IncidentID'].has_key('content')):
                ret['uuid'] = incident['IncidentID']['content']
            ret['source'] = incident['IncidentID']['name']
            ret['description'] = incident['Description']
            ret['confidence'] = incident['Assessment']['Confidence']['content']

            if(incident['EventData'].has_key('AdditionalData')):
                data = incident['EventData']['AdditionalData']
                dlist = [] 
                if(type(data) == dict):
                    dlist.extend([data])
                else:
                    dlist = data

                for d in dlist:
                    if d['meaning'] == 'malware_md5':
                        ret['malware_md5'] = d['content']
                    if d['meaning'] == 'malware_sha1':
                        ret['malware_md5'] = d['content']
                    if d['meaning'] == 'md5':
                        ret['md5'] = d['content']
                    if d['meaning'] == 'sha1':
                        ret['sha1'] = d['content']

            if(incident.has_key('RelatedActvity')):
                ret['relatedid'] = incident['RelatedActivity']['IncidentID']

            if(incident.has_key('AlternativeID')):
                if incident['AlternativeID']['IncidentID'].has_key('content'):
                    ret['alternativeid'] = incident['AlternativeID']['IncidentID']['content']
                    ret['alternativeid_restriction'] = incident['AlternativeID']['IncidentID']['restriction']
                else:
                    ret['alternativeid'] = None
                    ret['alternativeid_restriction'] = None

            ret['impact'] = impact
            ret['severity'] = None
            if(type(impact) == dict):
                severity = incident['Assessment']['Impact']['severity']
                impact = impact['content']
                ret['severity'] = severity
                ret['impact'] = impact

            if(incident['EventData'].has_key('Flow')):
                system = incident['EventData']['Flow']['System']
                ret['address'] = system['Node']['Address']
                if(type(ret['address']) == dict):
                    ret['address'] = ret['address']['content']
                if(system.has_key('Service')):
                    ret['protocol'] = system['Service']['ip_protocol']
                    ret['portlist'] = system['Service']['Portlist']

            return ret
                

    def table(self,feed):
        """
        Take in the JSON object and print a neat table out of the data

        Keyword args:
        self -- self
        feed -- feed dict
        """
        
        j = feed.get('feed')
        created = j.get('detecttime') 
        feedid = j.get('id')
        restriction = j.get('restriction')
        entries = j['entry']
        severity = j.get('severity')
        
        t = Texttable(max_width=0)
        t.set_deco(Texttable.VLINES)
        dlist = []
        for incident in entries:
            if(type(incident) == dict):
                x = self.simple(incident['Incident'])
                dlist.extend([x])
            else:
                for i in incident:
                    x = self.simple(i['Incident'])
                    dlist.extend(x)

        if self.fields:
            cols = self.fields
        else:
            cols = ['restriction','severity']
            if dlist[0].has_key('address'):
                cols.extend(['address','protocol','portlist'])

            if dlist[0].has_key('md5'):
                cols.extend(['md5'])

            if dlist[0].has_key('sha1'):
                cols.extend('sha1')

            if dlist[0].has_key('malware_md5'):
                cols.extend(['malware_md5'])

            if dlist[0].has_key('malware_sha1'):
                cols.extend(['malware_sha1'])


            cols.extend(['detecttime','description','alternativeid_restriction','alternativeid'])
        
        t.add_row(cols)
        for item in dlist:
            for col in cols:
                if isinstance(item[col],unicode):
                    item[col] = item[col].encode('utf-8')

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
    def __init__(self, path=None, fields=None, severity=None, restriction=None, nolog=None, confidence=None):
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
