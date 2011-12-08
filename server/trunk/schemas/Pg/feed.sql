SET default_tablespace = 'index';
DROP TABLE IF EXISTS feed CASCADE;
CREATE TABLE feed (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid NOT NULL,
    description text default 'feed',
    source uuid,
    guid uuid,
    hash_sha1 varchar(40),
    signature text,
    impact VARCHAR(140) default 'feed',
    severity severity,
    confidence real,
    restriction restriction not null default 'private',
    detecttime timestamp with time zone default NOW(),
    created timestamp with time zone DEFAULT NOW(),
    data text,
    UNIQUE (uuid)
);

CREATE INDEX idx_feed ON feed (detecttime DESC, severity DESC, confidence DESC, restriction DESC);

CREATE TABLE feed_search () INHERITS (feed);
ALTER TABLE feed_search ADD PRIMARY KEY (id);
-- ALTER TABLE feed_search ADD CONSTRAINT feed_search_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE feed_search ADD UNIQUE(uuid);
