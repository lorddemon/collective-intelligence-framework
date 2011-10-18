from setuptools import setup, find_packages

setup(
    name='cif',
    version='0.01_09',
    description="a sample python client for accessing the CIF interface",
    author = 'Wes Young',
    author_email = 'ci-framework@googlegroups.com',
#    url = 'http://code.google.com/p/collective-intelligence-framework/',
    license = 'GPLv2',
    packages=find_packages(),
    zip_safe = False,
    install_requires= ['httplib2 >= 0.7.1','simplejson >= 2.1.1','Texttable','argparse'],
    ## TODO -- change this to entry points instead of scripts
    scripts = [
        'scripts/cifcli.py'
    ]
)
