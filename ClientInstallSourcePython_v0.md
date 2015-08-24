# Known Issues #
the [PythonClient](ClientInstallSourcePython_v0.md) is currently **[UNSTABLE](http://code.google.com/p/collective-intelligence-framework/issues/detail?id=82)** and being re-written, use at your own risk or switch to the [PerlClient](ClientInstallSourcePerl_v0.md)
  1. httplib2 TLS issues
  1. no plugin support
  1. no proxy support

# Installation #

  1. make sure setup tools is installed
  1. easy\_install [cif](http://pypi.python.org/pypi?:action=pkg_edit&name=cif)
  1. setup your [configuration file](CliGlobalConfigurationFile_v0.md)
  1. run a sample query for testing:
```
$> cifcli.py -h
$> cifcli.py -h
$> cifcli.py -q example.com
$> cifcli.py -q 192.168.1.1
$> cifcli.py -q c09bdd5529fa4111758a7e8de0d615a6
$> cifcli.py -q url/246c9fa16cdc19411ace5cb43c301d2c
$> cifcli.py -q malware -s medium -c 40
$> cifcli.py -q infrastructure
$> cifcli.py -q infrastructure/network
$> cifcli.py -q domain
$> cifcli.py -q url -s low | grep -v private
```