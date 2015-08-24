# Introduction #



The cif-protocol is a low level encapsulation protocol that enables the transport of CIF messages throughout the framework. This protocol defines two types of objects, a top level raw 'msg' object, which acts like an envelope, as well as a 'feed' object that encapsulates feeds of data.

A current version of the v1 protocol can be found [here](https://github.com/collectiveintel/cif-protocol/tree/v1)

# Details #
## MessageType ##

---

The ['MessageType'](https://github.com/collectiveintel/cif-protocol/blob/v1/src/msg.proto) acts as an envelope to other data. It is used to convey if the message is a 'query', a 'submission', or a data 'reply'. It also contains the apikey and any status information needed to execute the transaction.

```
message MessageType {
    enum StatusType {
        SUCCESS         = 1;
        FAILED          = 2;
        UNAUTHORIZED    = 3;
    }
    enum MsgType {
        QUERY       = 1;
        SUBMISSION  = 2;
        REPLY       = 3;
    }
    message QueryStruct {
        required string query   = 1;
        optional bool nolog     = 2;
    }
    message QueryType {
        optional string apikey      = 1;
        optional string guid        = 2;
        optional int32 limit        = 3;
        optional int32 confidence   = 4;
        repeated QueryStruct query  = 5;
        optional string description = 6;
        optional bool feed          = 7 [ default = false ];
    }
    message SubmissionType {
        optional string guid    = 1;
        repeated bytes data     = 2;
    }

    required string version     = 1;
    required MsgType type       = 2;
    optional StatusType status  = 3;
    
    optional string apikey      = 4;
    repeated bytes data         = 5;
}
```

**version**
> required. string.

**type**
> required. enum. MsgType.

**status**
> optional. enum. StatusType.

**apikey**
> optional. string.

**data**
> repeated. bytes.

### StatusType ###
An enumeration that represents result information pertaining to the transaction.
```
    enum StatusType {
        SUCCESS         = 1;
        FAILED          = 2;
        UNAUTHORIZED    = 3;
    }
```

### MsgType ###
An enumeration that represents the type of message being transmitted.
```
    enum MsgType {
        QUERY       = 1;
        SUBMISSION  = 2;
        REPLY       = 3;
    }
```

### QueryStruct ###
An object that represents a query, typically embedded in a QueryType object.

```
    message QueryStruct {
        required string query   = 1;
        optional bool nolog     = 2;
    }
```

**query**
> required string. represents the question to ask

**nolog**
> optional. boolean. denotes whether or not the query should be logged

### QueryType ###
An object that represents a set of queries, wrapped in specific metadata.

```
    message QueryType {
        optional string apikey      = 1;
        optional string guid        = 2;
        optional int32 limit        = 3;
        optional int32 confidence   = 4;
        repeated QueryStruct query  = 5;
        optional string description = 6;
        optional bool feed          = 7 [ default = false ];
    }
```

**apikey**
> optional. string. an authorization key.

**guid**
> optional. string. an associated group id.

**limit**
> optional. int32. the max number of results to return.

**confidence**
> optional. int32. the minimal confidence value to apply to the results.

**query**
> repeated. enum QueryStruct. the query to be executed.

**description**
> optional. string. metadata about the transaction.

**feed**
> optional. boolean. depicts if the result is a pre-generated feed, or live, up-to-date results.

### SubmissionType ###
An object that holds submission data. Allows for a group id to be assigned to the submission. When MessageType points to data, if the MsgType is 'SUBMISSION', SubmissionType will be used to encode the data.

```
    message SubmissionType {
        optional string guid    = 1;
        repeated bytes data     = 2;
    }
```

**guid**
> optional. string.

**data**
> repeated. bytes.

## FeedType ##

---

The ['FeedType'](https://github.com/collectiveintel/cif-protocol/blob/v1/src/feed.proto) represents a dataset or contiguous set of records. It wraps these in a set of metadata such as confidence, description, restriction, reporttime, etc. It's also responsible for conveying the 'restriction map' and 'group map' back to the client. A 'FeedType' blob will be encapsulated in a 'MessageType' message.
```
message FeedType {
    enum RestrictionType {
        restriction_type_default        = 1;
        restriction_type_need_to_know   = 2;
        restriction_type_private        = 3;
        restriction_type_public         = 4;
    }
    message MapType {
        required string key = 1;
        required string value = 2;
    }

    required string version                  = 1;
    optional string guid                    = 2;

    optional int32 confidence               = 3;

    required string description             = 4;
    required string ReportTime              = 5;
    optional RestrictionType restriction    = 6;
    repeated MapType restriction_map        = 7;
    repeated MapType group_map              = 8;

    repeated bytes data                     = 9;
    
    optional string uuid                    = 10;
    optional int32 query_limit              = 11;
    
    repeated MapType feeds_map              = 12;
}
```

**version**
> required. string. protocol version.

**guid**
> optional. string. the group id associated with the data.

**confidence**
> optional. int32. associated confidence level of the feed data-set overall.

**description**
> required. string. a description of the feed data-set.

**ReportTime**
> required. string. a timestamp in which the data was generated, typically in the format 'YYYY-MM-DDThh:mm:ssZ'

**restriction**
> optional. enum RestrictionType. restriction of the complete feed data-set

**restriction\_map**
> repeated. enum MapType. a map of restriction values (eg: IODEF to TLP) for a client to translate and represent locally.

**group\_map**
> repeated. enum MapType. a map of the guid values for a client to translate and represent locally.

**data**
> repeated. bytes. the payload.

**uuid**
> optional. string. a unique identifier representing the feed data-set.

**query\_limit**
> optional. int32. used to inform a client when a router has overwritten a limit value.

**feed\_map**
> repeated. enum MapType. a map of feeds avail from the router.

### RestrictionType ###
An enumeration copied from RFC 5070 representing a simple set of restrictions.

```
    enum RestrictionType {
        restriction_type_default        = 1;
        restriction_type_need_to_know   = 2;
        restriction_type_private        = 3;
        restriction_type_public         = 4;
    }
```
### MapType ###
A basic "key pair value" structure, used in group maps, restriction maps, feed maps, etc.
```
    message MapType {
        required string key = 1;
        required string value = 2;
    }
```