DROP TABLE IF EXISTS email CASCADE;
CREATE TABLE email (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES archive(uuid) ON DELETE CASCADE NOT NULL,
    description text,
    address text,
    source uuid,
    impact varchar(140),
    confidence real,
    severity severity,
    restriction restriction not null default 'private',
    alternativeid text,
    alternativeid_restriction restriction not null default 'private',
    detecttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW(),
    UNIQUE (uuid)
);

CREATE TABLE email_search() INHERITS (email);
ALTER TABLE email_search ADD PRIMARY KEY (id);
ALTER TABLE email_search ADD CONSTRAINT email_search_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE email_search ADD UNIQUE(uuid);
