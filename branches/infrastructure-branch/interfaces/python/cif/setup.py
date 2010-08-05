from setuptools import setup, find_packages

setup(
    name='cif',
    version='0.00_03',
    description="",
    author="Wes Young",
    packages=find_packages(),
    zip_safe = False,
    install_requires= ['restclient','simplejson','Texttable'],
)
