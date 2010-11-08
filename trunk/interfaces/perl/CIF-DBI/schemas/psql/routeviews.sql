DROP TABLE IF EXISTS routeviews;
CREATE TABLE routeviews (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    sha1 varchar(64) NOT NULL,
    asn integer NOT NULL,
    asn_desc varchar(140),
    cc varchar(2),
    rir varchar(10),
    prefix inet NOT NULL,
    cidr inet NOT NULL,
    peer integer NOT NULL,
    peer_desc varchar(140),
    detecttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW(),
    UNIQUE(sha1)
);
