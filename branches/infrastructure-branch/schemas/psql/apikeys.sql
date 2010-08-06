DROP TABLE IF EXISTS apikeys;
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    email text NOT NULL,
    firstname text,
    lastname text,
    affiliation text,
    created timestamp with time zone DEFAULT NOW(),
    UNIQUE(email)
);

CREATE TABLE apikeys (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    apikey uuid NOT NULL,
    userid bigint REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    created timestamp with time zone DEFAULT NOW(),
    UNIQUE(apikey,userid)
);
