DROP TABLE IF EXISTS domains_whitelist;
DROP TABLE IF EXISTS domains_fastflux;
DROP TABLE IF EXISTS domains_nameservers;
DROP TABLE IF EXISTS domains_malware;
DROP TABLE IF EXISTS domains_botnet;
DROP TABLE IF EXISTS domains_passivedns;
DROP TABLE IF EXISTS domains;

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
    UNIQUE (uuid)
);

CREATE TABLE domains_whitelist() INHERITS (domains);
ALTER TABLE domains_whitelist ADD PRIMARY KEY (id);
ALTER TABLE domains_whitelist ADD CONSTRAINT whitelist_domains_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE domains_whitelist ADD UNIQUE(uuid);

CREATE TABLE domains_fastflux() INHERITS (domains);
ALTER TABLE domains_fastflux ADD PRIMARY KEY (id);
ALTER TABLE domains_fastflux ADD CONSTRAINT domains_fastflux_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE domains_fastflux ADD UNIQUE(uuid);

CREATE TABLE domains_nameservers() INHERITS (domains);
ALTER TABLE domains_nameservers ADD PRIMARY KEY (id);
ALTER TABLE domains_nameservers ADD CONSTRAINT domains_nameservers_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE domains_nameservers ADD UNIQUE(uuid);

CREATE TABLE domains_malware() INHERITS (domains);
ALTER TABLE domains_malware ADD PRIMARY KEY (id);
ALTER TABLE domains_malware ADD CONSTRAINT domains_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE domains_malware ADD UNIQUE(uuid);

CREATE TABLE domains_botnet() INHERITS (domains);
ALTER TABLE domains_botnet ADD PRIMARY KEY (id);
ALTER TABLE domains_botnet ADD CONSTRAINT domains_botnet_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE domains_botnet ADD UNIQUE(uuid);

CREATE TABLE domains_passivedns() INHERITS (domains);
ALTER TABLE domains_passivedns ADD PRIMARY KEY (id);
ALTER TABLE domains_passivedns ADD CONSTRAINT domains_passivedns_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE domains_passivedns ADD UNIQUE(uuid);
