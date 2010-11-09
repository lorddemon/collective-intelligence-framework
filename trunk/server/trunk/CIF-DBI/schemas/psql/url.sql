DROP TABLE IF EXISTS urls_malware;
DROP TABLE IF EXISTS urls_phishing;
DROP TABLE IF EXISTS urls;

CREATE TABLE urls (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    description text,
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
    alternativeid text,
    alternativeid_restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    detecttime timestamp with time zone,
    created timestamp with time zone DEFAULT NOW(),
    UNIQUE (uuid)
);

CREATE TABLE urls_malware () INHERITS (urls);
ALTER TABLE urls_malware ADD PRIMARY KEY (id);
ALTER TABLE urls_malware ADD UNIQUE(uuid);
ALTER TABLE urls_malware ADD CONSTRAINT urls_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;

CREATE TABLE urls_phishing () INHERITS (urls);
ALTER TABLE urls_phishing ADD PRIMARY KEY (id);
ALTER TABLE urls_phishing ADD UNIQUE(uuid);
ALTER TABLE urls_phishing ADD CONSTRAINT urls_phishing_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
