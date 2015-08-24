# CIFv1 Distributed Environment #

**Table of Contents**


cif v1 is architected in a way that allows it's major components to be distributed among many hosts when a single host becomes resource constrained.

### Key ###

#### libcif ####
  * query cif
  * submit data to cif
  * get feeds from cif

#### cif-smart ####
  * parse data sets
  * run post processors on parsed data sets
    * dns resolution
    * bgp resolution
    * domain resolution from urls
    * malware resolution from TC MW hash reg
    * bgp prefix whitelisting

#### cif-router ####
  * peers with clients giving access to data-warehouse
  * peers with other routers

#### postgresql ####
  * data store

## One server ##

With a single server every component is installed on the same host and must share resources (cpu and i/o) with the other components.

<table border='0' cellspacing='25' valign='center'>
<tbody>
<tr>
<td align='center'><img src='http://collective-intelligence-framework.googlecode.com/files/cifv1_one_server_06.png' width='400'></img></td>
</tr>
</tbody>
</table>

## Two servers ##

When you hit resource constraints with one server, it is likely the first component you would split out is the postgresql database.

<table border='0' cellspacing='25' valign='center'>
<tbody>
<tr>
<td align='center'><img src='http://collective-intelligence-framework.googlecode.com/files/cifv1_two_servers_03.png' width='500'></img></td>
</tr>
</tbody>
</table>

## Six servers ##

With three or more servers you can dedicate one or more servers per component. This allows you to add additional resources as needed.

This also gives high availability capabilities as demonstrated below with a load balancer in front of the two cif-routers and a postgresql in a master-slave configuration.

You may notice that postgresql could become the ultimate bottleneck when dealing with big data. In cif v2, [HBase](http://hbase.apache.org) will be a optional data store; stay tuned!

<table border='0' cellspacing='25' valign='center'>
<tbody>
<tr>
<td align='center'><img src='http://collective-intelligence-framework.googlecode.com/files/cifv1_six_servers_04.png' width='600'></img></td>
</tr>

</tbody>
</table>