CREATE TABLE asn (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    description text,
    address integer NOT NULL,
    peers text,
    cc varchar(5),
    rir varchar(10),
    confidence REAL CHECK (confidence >= 0.0 AND 10.0 >= confidence),
    source uuid NOT NULL,
    severity VARCHAR(6) CHECK (severity IN ('low','medium','high')),
    restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    whois text,
    tsv tsvector,
    detecttime timestamp with time zone,
    created timestamp with time zone DEFAULT NOW()
);
