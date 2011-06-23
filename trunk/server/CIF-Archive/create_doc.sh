#!/bin/bash

cd doc/
postgresql_autodoc -d cif -U postgres
dot -Tpng -o cif.png cif.dot
