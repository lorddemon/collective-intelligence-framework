DROP TABLE domains_whitelist;
DROP TABLE fastflux_domains;
DROP TABLE suspicious_nameservers;
DROP TABLE malicious_domains;
DROP TABLE domains;
CREATE TABLE domains (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    description text,
    address text,
    type VARCHAR(10),
    rdata varchar(255),
    cidr inet,
    asn int,
    asn_desc text, 
    cc varchar(5),
    rir varchar(10),
    class VARCHAR(10),
    ttl int,
    whois text,
    impact VARCHAR(140),
    confidence REAL,
    source uuid NOT NULL,
    alternativeid text,
    alternativeid_restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    severity VARCHAR(6) CHECK (severity IN ('low','medium','high')),
    restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    detecttime timestamp with time zone,
    created timestamp with time zone DEFAULT NOW(),
    tsv tsvector,
    UNIQUE (uuid)
);

CREATE TABLE domains_whitelist() INHERITS (domains);
ALTER TABLE domains_whitelist ADD PRIMARY KEY (id);
ALTER TABLE domains_whitelist ADD CONSTRAINT whitelist_domains_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE domains_whitelist ADD UNIQUE(uuid);

CREATE TABLE fastflux_domains() INHERITS (domains);
ALTER TABLE fastflux_domains ADD PRIMARY KEY (id);
ALTER TABLE fastflux_domains ADD CONSTRAINT fastflux_domains_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE fastflux_domains ADD UNIQUE(uuid);

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON fastflux_domains FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,impact,asn_desc,whois);

CREATE TABLE suspicious_nameservers() INHERITS (domains);
ALTER TABLE suspicious_nameservers ADD PRIMARY KEY (id);
ALTER TABLE suspicious_nameservers ADD CONSTRAINT suspicious_nameservers_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE suspicious_nameservers ADD UNIQUE(uuid);

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON suspicious_nameservers FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,impact,asn_desc,whois);

CREATE TABLE malicious_domains() INHERITS (domains);
ALTER TABLE malicious_domains ADD PRIMARY KEY (id);
ALTER TABLE malicious_domains ADD CONSTRAINT malicious_domains_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE malicious_domains ADD UNIQUE(uuid);

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON malicious_domains FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,impact,asn_desc,whois);

CREATE TABLE passive_domains() INHERITS (domains);
ALTER TABLE passive_domains ADD PRIMARY KEY (id);
ALTER TABLE passive_domains ADD CONSTRAINT passive_omains_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE passive_domains ADD UNIQUE(uuid);

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON passive_domains FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,impact,asn_desc,whois);
