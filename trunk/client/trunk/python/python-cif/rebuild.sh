python setup.py clean -a
rm dist -R -f
python setup.py sdist
python setup.py bdist
