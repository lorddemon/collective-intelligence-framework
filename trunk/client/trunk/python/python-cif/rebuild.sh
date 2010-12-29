sudo python setup.py clean -a
sudo rm dist -R -f
python setup.py sdist
python setup.py bdist
