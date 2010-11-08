--
-- parent table (for show only)
--

DROP view IF EXISTS v_infrastructure;
DROP TABLE IF EXISTS infrastructure_scanner;
DROP TABLE IF EXISTS infrastructure_spam;
DROP TABLE IF EXISTS infrastructure_malware;
DROP TABLE IF EXISTS infrastructure_botnet;
DROP TABLE IF EXISTS infrastructure_whitelist;
DROP TABLE IF EXISTS infrastructure_network;
DROP TABLE IF EXISTS infrastructure_suspicious;
DROP TABLE IF EXISTS infrastructure_phishing;

DROP TABLE IF EXISTS infrastructure;
CREATE TABLE infrastructure (
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
    detecttime timestamp with time zone,
    created timestamp with time zone DEFAULT NOW()
);

--
-- default view
--

CREATE VIEW v_infrastructure as
SELECT infrastructure.*,v_messages.type,v_messages.format,v_messages.structured
FROM infrastructure
LEFT JOIN v_messages ON (v_messages.uuid = infrastructure.uuid);

--
-- infrastructure_botnet
---

CREATE TABLE infrastructure_botnet () INHERITS (infrastructure);
ALTER TABLE infrastructure_botnet ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_botnet ADD CONSTRAINT infrastructure_botnet_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_botnet ADD UNIQUE(uuid);

--
-- infrastructure_malware
---

CREATE TABLE infrastructure_malware () INHERITS (infrastructure);
ALTER TABLE infrastructure_malware ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_malware ADD CONSTRAINT infrastructure_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_malware ADD UNIQUE(uuid);

--
-- infrastructure_whitelist
---

CREATE TABLE infrastructure_whitelist () INHERITS (infrastructure);
ALTER TABLE infrastructure_whitelist ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_whitelist ADD CONSTRAINT infrastructure_whitelist_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_whitelist ADD UNIQUE(uuid);

--
-- infrastructure_scanner
--

CREATE TABLE infrastructure_scanner () INHERITS (infrastructure);
ALTER TABLE infrastructure_scanner ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_scanner ADD CONSTRAINT infrastructure_scanner_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_scanner ADD UNIQUE(uuid);

--
-- infrastructure_spam 
--

CREATE TABLE infrastructure_spam () INHERITS (infrastructure);
ALTER TABLE infrastructure_spam ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_spam ADD CONSTRAINT infrastructure_spam_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_spam ADD UNIQUE(uuid);

--
-- infrastructure_network
--

CREATE TABLE infrastructure_network () INHERITS (infrastructure);
ALTER TABLE infrastructure_network ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_network ADD CONSTRAINT infrastructure_network_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_network ADD UNIQUE(uuid);

CREATE TABLE infrastructure_suspicious () INHERITS (infrastructure);
ALTER TABLE infrastructure_suspicious ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_suspicious ADD CONSTRAINT infrastructure_suspicious_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_suspicious ADD UNIQUE(uuid);

CREATE TABLE infrastructure_phishing () INHERITS (infrastructure);
ALTER TABLE infrastructure_phishing ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_phishing ADD CONSTRAINT infrastructure_phishing_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_phishing ADD UNIQUE(uuid);

CREATE TABLE infrastructure_asn () INHERITS (infrastructure);
ALTER TABLE infrastructure_asn ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_asn ADD CONSTRAINT infrastructure_asn_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_asn ADD UNIQUE(uuid);
