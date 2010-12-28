#!/usr/bin/python

from cif.client import ClientINI

rclient = ClientINI()
r = rclient.GET('infrastructure','high')
#r = rclient.GET('213.109.96.0/22')
print rclient.table(r)
