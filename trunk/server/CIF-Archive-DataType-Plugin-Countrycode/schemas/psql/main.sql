DROP TABLE IF EXISTS countrycode CASCADE;
CREATE TABLE countrycode (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES archive(uuid) ON DELETE CASCADE NOT NULL,
    cc varchar(5),
    source uuid NOT NULL,
    severity severity,
    confidence REAL CHECK (confidence >= 0.0 AND 10.0 >= confidence),
    restriction restriction not null default 'private',
    detecttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW()
);
