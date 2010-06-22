DROP TABLE domains;
CREATE TABLE domains (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    description text,
    address text,
    type VARCHAR(10),
    rdata varchar(255),
    cidr inet,
    asn int,
    asn_desc text, 
    cc varchar(5),
    rir varchar(10),
    class VARCHAR(10),
    ttl int,
    whois text,
    impact VARCHAR(140),
    confidence REAL,
    source uuid NOT NULL,
    alternativeid text,
    alternativeid_restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    severity VARCHAR(6) CHECK (severity IN ('low','medium','high')),
    restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    detecttime timestamp with time zone,
    created timestamp with time zone DEFAULT NOW(),
    tsv tsvector,
    UNIQUE (uuid)
);

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON domains FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,address,whois);
