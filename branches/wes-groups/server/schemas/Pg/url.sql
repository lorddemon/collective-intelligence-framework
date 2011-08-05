DROP TABLE IF EXISTS url CASCADE;
CREATE TABLE url (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES archive(uuid) ON DELETE CASCADE NOT NULL,
    address text,
    source uuid,
    guid uuid,
    confidence REAL,
    severity severity,
    restriction restriction not null default 'private',
    detecttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW(),
    UNIQUE (uuid)
);

CREATE TABLE url_botnet () INHERITS (url);
ALTER TABLE url_botnet ADD PRIMARY KEY (id);
ALTER TABLE url_botnet ADD UNIQUE(uuid);
ALTER TABLE url_botnet ADD CONSTRAINT url_botnet_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;

CREATE TABLE url_malware () INHERITS (url);
ALTER TABLE url_malware ADD PRIMARY KEY (id);
ALTER TABLE url_malware ADD UNIQUE(uuid);
ALTER TABLE url_malware ADD CONSTRAINT url_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;

CREATE TABLE url_phishing () INHERITS (url);
ALTER TABLE url_phishing ADD PRIMARY KEY (id);
ALTER TABLE url_phishing ADD UNIQUE(uuid);
ALTER TABLE url_phishing ADD CONSTRAINT url_phishing_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;

CREATE TABLE url_search () INHERITS (url);
ALTER TABLE url_search ADD PRIMARY KEY (id);
ALTER TABLE url_search ADD UNIQUE(uuid);
ALTER TABLE url_search ADD CONSTRAINT url_search_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
