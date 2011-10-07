from setuptools import setup, find_packages

setup(
    name='cif',
    version='0.01_05',
    description="a sample python client for accessing the CIF interface",
    author = 'Wes Young',
    author_email = 'ci-framework@googlegroups.com',
#    url = 'http://code.google.com/p/collective-intelligence-framework/',
    license = 'BSD',
    packages=find_packages(),
    zip_safe = False,
    install_requires= ['httplib2','simplejson','Texttable','argparse'],
    ## TODO -- change this to entry points instead of scripts
    scripts = [
        'scripts/cifcli.py'
    ]
)
