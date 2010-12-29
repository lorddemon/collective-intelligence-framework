from setuptools import setup, find_packages

setup(
    name='cif',
    version='0.00_04',
    description="",
    author = 'Wes Young',
    author_email = 'ci-framework@googlegroups.com',
    url = 'http://code.google.com/p/collective-intelligence-framework/',
    license = 'BSD',
    packages=find_packages(),
    zip_safe = False,
    install_requires= ['restclient','simplejson','Texttable','python-magic','argparse'],
    scripts = [
        'scripts/cifcli.py'
    ]
)
