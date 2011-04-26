DROP TABLE IF EXISTS asn CASCADE;
CREATE TABLE asn (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES archive(uuid) ON DELETE CASCADE NOT NULL,
    description text,
    asn float not null,
    asn_desc text,
    cc varchar(2),
    source uuid NOT NULL,
    severity severity,
    restriction restriction not null default 'private',
    alternativeid text,
    alternativeid_restriction restriction not null default 'private',
    detecttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW()
);
