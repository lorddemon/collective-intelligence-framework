# Introduction #

This document describes how to migrate apikeys from a v0 instance to a v1 instance. This doc assumes your v0 instance is at-least 0.06 or higher (in which the cif\_apikeys utility includes export support for keys)

# Details #
## Caveats ##
  * If you've set any "access restrictions", these will not be copied over as they've been re-architected in v1.
  * this will copy over revoked keys, be sure to do adequate testing prior to releasing into production
## Migration ##
  1. be sure your v0 instance is updated to 0.06 (or higher)
  1. log into your v0 instance as the 'cif' user
  1. export the apikeys to a file
```
$ /opt/cif/bin/cif_apikeys -E > ~/v0_apikeys
```
  1. copy this file to your v1 instance (be sure to use SSH or some form of encrypted medium, your apikeys are in clear text)
  1. login to your v1 instance as the 'cif' user
  1. import the keys
```
$ /opt/cif/bin/cif_apikeys -I -L ~/v0_apikeys
```