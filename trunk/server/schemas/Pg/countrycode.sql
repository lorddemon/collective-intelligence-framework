SET default_tablespace = 'index';
DROP TABLE IF EXISTS countrycode CASCADE;
CREATE TABLE countrycode (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES archive(uuid) ON DELETE CASCADE NOT NULL,
    cc varchar(5),
    source uuid NOT NULL,
    guid uuid,
    severity severity,
    confidence REAL,
    restriction restriction not null default 'private',
    detecttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW(),
    unique(uuid,cc)
);

CREATE INDEX idx_feed_countrycode ON asn (detecttime DESC, severity DESC, confidence DESC);
