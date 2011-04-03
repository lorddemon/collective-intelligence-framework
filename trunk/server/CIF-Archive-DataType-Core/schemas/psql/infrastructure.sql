--
-- parent table (for show only)
--

DROP TABLE IF EXISTS infrastructure CASCADE;
CREATE TABLE infrastructure (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES archive(uuid) ON DELETE CASCADE NOT NULL,
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
    severity severity,
    restriction restriction not null default 'private',
    alternativeid text,
    alternativeid_restriction restriction not null default 'private',
    whois text,
    detecttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW()
);

--
-- infrastructure_botnet
---

CREATE TABLE infrastructure_botnet () INHERITS (infrastructure);
ALTER TABLE infrastructure_botnet ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_botnet ADD CONSTRAINT infrastructure_botnet_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_botnet ADD UNIQUE(uuid);

--
-- infrastructure_malware
---

CREATE TABLE infrastructure_malware () INHERITS (infrastructure);
ALTER TABLE infrastructure_malware ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_malware ADD CONSTRAINT infrastructure_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_malware ADD UNIQUE(uuid);

--
-- infrastructure_whitelist
---

CREATE TABLE infrastructure_whitelist () INHERITS (infrastructure);
ALTER TABLE infrastructure_whitelist ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_whitelist ADD CONSTRAINT infrastructure_whitelist_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_whitelist ADD UNIQUE(uuid);

--
-- infrastructure_scanner
--

CREATE TABLE infrastructure_scanner () INHERITS (infrastructure);
ALTER TABLE infrastructure_scanner ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_scanner ADD CONSTRAINT infrastructure_scanner_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_scanner ADD UNIQUE(uuid);

--
-- infrastructure_spam 
--

CREATE TABLE infrastructure_spam () INHERITS (infrastructure);
ALTER TABLE infrastructure_spam ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_spam ADD CONSTRAINT infrastructure_spam_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_spam ADD UNIQUE(uuid);

--
-- infrastructure_network
--

CREATE TABLE infrastructure_network () INHERITS (infrastructure);
ALTER TABLE infrastructure_network ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_network ADD CONSTRAINT infrastructure_network_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_network ADD UNIQUE(uuid);

CREATE TABLE infrastructure_suspicious () INHERITS (infrastructure);
ALTER TABLE infrastructure_suspicious ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_suspicious ADD CONSTRAINT infrastructure_suspicious_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_suspicious ADD UNIQUE(uuid);

CREATE TABLE infrastructure_phishing () INHERITS (infrastructure);
ALTER TABLE infrastructure_phishing ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_phishing ADD CONSTRAINT infrastructure_phishing_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_phishing ADD UNIQUE(uuid);

CREATE TABLE infrastructure_asn () INHERITS (infrastructure);
ALTER TABLE infrastructure_asn ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_asn ADD CONSTRAINT infrastructure_asn_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_asn ADD UNIQUE(uuid);

CREATE TABLE infrastructure_search () INHERITS (infrastructure);
ALTER TABLE infrastructure_search ADD PRIMARY KEY (id);
ALTER TABLE infrastructure_search ADD CONSTRAINT infrastructure_search_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE infrastructure_search ADD UNIQUE(uuid);
