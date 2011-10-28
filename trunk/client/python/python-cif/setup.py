from setuptools import setup, find_packages

setup(
    name='cif',
    version='0.01_12',
    description="a sample python client for accessing the CIF interface",
    author = 'Wes Young',
    author_email = 'ci-framework@googlegroups.com',
#    url = 'http://code.google.com/p/collective-intelligence-framework/',
    license = 'GPLv2',
    packages=find_packages(),
    zip_safe = False,
    install_requires= ['httplib2 >= 0.7.1','simplejson >= 2.1.1','Texttable','argparse','SocksiPy >= 1.0-1'],
    ## TODO -- change this to entry points instead of scripts
    scripts = [
        'scripts/cifcli.py'
    ]
)
