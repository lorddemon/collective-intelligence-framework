DROP TABLE inet_whois;
DROP TABLE domain_whois;
DROP TABLE whois;
CREATE TABLE whois (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    type VARCHAR(6) CHECK (type IN ('domain','inet')),
    description VARCHAR(140),
    impact VARCHAR(140),
    whois text,
    tsv tsvector,
    created timestamp with time zone DEFAULT NOW(),
    UNIQUE (uuid,description)
);

CREATE TABLE inet_whois (
    address inet NOT NULL,
    type VARCHAR(6) DEFAULT 'inet',
    cidr inet,
    asn int,
    asn_desc varchar(140)
) INHERITS (whois);

ALTER TABLE inet_whois ADD PRIMARY KEY (id);
ALTER TABLE inet_whois ADD UNIQUE(uuid,address);
ALTER TABLE inet_whois ADD CONSTRAINT inet_whois_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON inet_whois FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,impact,asn_desc,whois);

CREATE TABLE domain_whois (
    address text NOT NULL,
    type VARCHAR(6) DEFAULT 'domain'
) INHERITS (whois);

ALTER TABLE domain_whois ADD PRIMARY KEY (id);
ALTER TABLE domain_whois ADD UNIQUE(uuid,address);
ALTER TABLE domain_whois ADD CONSTRAINT domain_whois_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON domain_whois FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,impact,whois);
