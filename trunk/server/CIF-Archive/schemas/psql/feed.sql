DROP TABLE IF EXISTS feed CASCADE;
CREATE TABLE feed (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid NOT NULL REFERENCES archive(uuid) ON DELETE CASCADE,
    description text default 'feed',
    source uuid,
    hash_sha1 varchar(40),
    signature text,
    impact VARCHAR(140) default 'feed',
    severity severity,
    restriction restriction not null default 'private',
    detecttime timestamp with time zone default NOW(),
    created timestamp with time zone DEFAULT NOW(),
    archive text not null,
    UNIQUE (uuid)
);

create view v_feed as select id,uuid,restriction,severity,description,created from feed;
