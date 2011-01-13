DROP TABLE IF EXISTS asn CASCADE;

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
    severity severity,
    restriction restriction not null default 'private',
    whois text,
    detecttime timestamp with time zone,
    created timestamp with time zone DEFAULT NOW()
);
