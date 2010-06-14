DROP TABLE malware_urls;
DROP TABLE phishing_urls;
DROP TABLE urls;
CREATE TABLE urls (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    description VARCHAR(140),
    address text,
    url_md5 varchar(32),
    url_sha1 varchar(40),
    malware_md5 varchar(32),
    malware_sha1 varchar(40),
    source uuid,
    impact VARCHAR(140),
    confidence REAL,
    severity VARCHAR(6) CHECK (severity IN ('low','medium','high')),
    restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    detecttime timestamp with time zone,
    reporttime timestamp with time zone,
    created timestamp with time zone DEFAULT NOW(),
    tsv tsvector,
    UNIQUE (uuid)
);

CREATE TABLE malware_urls () INHERITS (urls);
ALTER TABLE malware_urls ADD PRIMARY KEY (id);
ALTER TABLE malware_urls ADD UNIQUE(uuid);
ALTER TABLE malware_urls ADD CONSTRAINT malware_url_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON malware_urls FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,address);

CREATE TABLE phishing_urls () INHERITS (urls);
ALTER TABLE phishing_urls ADD PRIMARY KEY (id);
ALTER TABLE phishing_urls ADD UNIQUE(uuid);
ALTER TABLE phishing_urls ADD CONSTRAINT phishing_url_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON phishing_urls FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,address);
