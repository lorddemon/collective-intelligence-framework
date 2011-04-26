DROP TABLE IF EXISTS relatedid CASCADE;
CREATE TABLE relatedid (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES archive(uuid) ON DELETE CASCADE NOT NULL,
    description text,
    relatedid uuid not null,
    source uuid NOT NULL,
    severity severity,
    restriction restriction not null default 'private',
    alternativeid text,
    alternativeid_restriction restriction not null default 'private',
    detecttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW()
);
