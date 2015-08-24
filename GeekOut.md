# Introduction #

This is a page written for Geeks that want to know about the underpinnings of CIF 1.0

## Database Schema ##

CIF store schemaless data in SQL. Inspired by the blog post titled "How Friendfeed uses MySQL to store schema-less data".

More:

Using a Relational Database for Schemaless Data - Best Practices<br>
<a href='http://stackoverflow.com/questions/4189709/using-a-relational-database-for-schemaless-data-best-practices'>http://stackoverflow.com/questions/4189709/using-a-relational-database-for-schemaless-data-best-practices</a>

Quora Infrastructure: Why does Quora use MySQL as the data store instead of NoSQLs such as Cassandra, MongoDB, or CouchDB?<br>
<a href='http://www.quora.com/Quora-Infrastructure/Why-does-Quora-use-MySQL-as-the-data-store-instead-of-NoSQLs-such-as-Cassandra-MongoDB-or-CouchDB'>http://www.quora.com/Quora-Infrastructure/Why-does-Quora-use-MySQL-as-the-data-store-instead-of-NoSQLs-such-as-Cassandra-MongoDB-or-CouchDB</a>

<h2>Architecture</h2>

CIF 1.0 was written to be distributed among many hosts if the volume of data consumes a single host's resources.<br>
<br>
cif-smrt<br>
<a href='https://github.com/collectiveintel/cif-smrt'>https://github.com/collectiveintel/cif-smrt</a>

cif-router<br>
<a href='https://github.com/collectiveintel/cif-router'>https://github.com/collectiveintel/cif-router</a>

libcif-dbi<br>
<a href='https://github.com/collectiveintel/libcif-dbi'>https://github.com/collectiveintel/libcif-dbi</a>

<h2>Technologies</h2>

ZeroMQ<br>
<a href='http://www.zeromq.org/'>http://www.zeromq.org/</a>

Protocol Buffers<br>
<a href='https://developers.google.com/protocol-buffers/'>https://developers.google.com/protocol-buffers/</a>

Snappy<br>
<a href='http://code.google.com/p/snappy/'>http://code.google.com/p/snappy/</a>

<h2>Features</h2>

<ul><li>Threading