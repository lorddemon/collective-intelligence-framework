CREATE TABLE phishing_replyto (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    description VARCHAR(140),
    address text,
    source uuid,
    source_weight integer,
    confidence REAL,
    severity VARCHAR(5) CHECK (severity IN ('low','medium','high')),
    restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    created timestamp with time zone DEFAULT NOW(),
    tsv tsvector,
    UNIQUE (uuid)
);

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON phishing_replyto FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,address);
