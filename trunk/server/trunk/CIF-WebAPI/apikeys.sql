DROP TABLE IF EXISTS apikeys;
CREATE TABLE apikeys (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    userid text NOT NULL,
    apikey uuid NOT NULL,
    created timestamp with time zone DEFAULT NOW(),
    UNIQUE(apikey,userid)
);
