--
-- parent table (for show only)
--

DROP view v_inet;
DROP TABLE scanners;
DROP TABLE spammers;
DROP TABLE infrastructure;

DROP TABLE inet;
CREATE TABLE inet (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES messages(uuid) ON DELETE CASCADE NOT NULL,
    description text,
    impact VARCHAR(140),
    address INET NOT NULL,
    cidr INET,
    asn integer,
    asn_desc text,
    cc varchar(5),
    rir varchar(10),
    protocol integer,
    portlist VARCHAR(255),
    confidence REAL CHECK (confidence >= 0.0 AND 10.0 >= confidence),
    source uuid NOT NULL,
    severity VARCHAR(6) CHECK (severity IN ('low','medium','high')),
    restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    alternativeid text,
    alternativeid_restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    whois text,
    tsv tsvector,
    detecttime timestamp with time zone,
    created timestamp with time zone DEFAULT NOW()
);

--
-- default view
--

CREATE VIEW v_inet as
SELECT inet.*,v_messages.type,v_messages.format,v_messages.structured,v_messages.tsv as message_tsv
FROM inet
LEFT JOIN v_messages ON (v_messages.uuid = inet.uuid);

--
-- scanners
--

CREATE TABLE scanners () INHERITS (inet);
ALTER TABLE scanners ADD PRIMARY KEY (id);
ALTER TABLE scanners ADD CONSTRAINT scanner_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE scanners ADD UNIQUE(uuid);

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON scanners FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,impact,asn_desc,whois);

--
-- infrastructure (C&C's, etc)
--

CREATE TABLE infrastructure () INHERITS (inet);
ALTER TABLE infrastructure ADD PRIMARY KEY (id);
ALTER TABLE infrastructure ADD CONSTRAINT infrastructure_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure ADD UNIQUE(uuid);

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON infrastructure FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,impact,asn_desc,whois);

--
-- Spammers
--

CREATE TABLE spammers () INHERITS (inet);
ALTER TABLE spammers ADD PRIMARY KEY (id);
ALTER TABLE spammers ADD CONSTRAINT spammer_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE spammers ADD UNIQUE(uuid);

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON spammers FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,impact,asn_desc,whois);

--
-- suspicious_networks
--

CREATE TABLE suspicious_networks () INHERITS (inet);
ALTER TABLE suspicious_networks ADD PRIMARY KEY (id);
ALTER TABLE suspicious_networks ADD CONSTRAINT suspicious_networks_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE suspicious_networks ADD UNIQUE(uuid);

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON suspicious_networks FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', description,impact,asn_desc,whois);
