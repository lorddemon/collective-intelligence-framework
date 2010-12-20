DROP TABLE IF EXISTS apikeys;
CREATE TABLE apikeys (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    userid text NOT NULL,
    parentid bigint default null,
    apikey uuid NOT NULL,
    revoked bool default null,
    access varchar(100) default 'all',
    write bool default null,
    created timestamp with time zone DEFAULT NOW(),
    UNIQUE(apikey,userid)
);
