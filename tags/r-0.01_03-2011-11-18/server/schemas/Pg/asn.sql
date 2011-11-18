SET default_tablespace = 'index';
DROP TABLE IF EXISTS asn CASCADE;
CREATE TABLE asn (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES archive(uuid) ON DELETE CASCADE NOT NULL,
    asn float not null,
    asn_desc text,
    source uuid NOT NULL,
    guid uuid,
    severity severity,
    confidence real,
    restriction restriction not null default 'private',
    detecttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW(),
    unique(uuid,asn)
);
