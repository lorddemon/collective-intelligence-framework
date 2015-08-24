# Introduction #

[ZeroMQ](http://www.zeromq.org) is used as a socket library for various communicative properties of cif, everything from inter-thread comm's to client/router comms. It requires the installation of the lower level C++ library as well as the perl XS interface.

# Details #
## Low level library ##
There are two different tree's in the zeromq family, 2.x and 3.x, CIF v1 leverages the 2.x family right now. Future versions may be built against the CZMQ api and be built against either code base.
```
$ wget http://download.zeromq.org/zeromq-2.2.0.tar.gz
$ tar -zxvf zeromq-2.2.0.tar.gz
$ cd zeromq-2.2.0
$ ./configure && make && sudo make install
$ sudo ldconfig
```

## Perl XS Interface ##
With the release of zeromq 3.x, the perl libraries have evolved into ZeroMQ (2.x) and ZMQ (2.x/3.x). CIF v1 relies on the ZeroMQ library. Future versions will be built against the "ZMQ" perl library.
```
$ sudo perl -MCPAN -e 'install ZeroMQ'
```