DROP TABLE IF EXISTS domain CASCADE;
CREATE TABLE domain (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES archive(uuid) ON DELETE CASCADE NOT NULL,
    address text,
    md5 varchar(32),
    sha1 varchar(40),
    type VARCHAR(10),
    confidence REAL,
    source uuid NOT NULL,
    severity severity,
    restriction restriction not null default 'private',
    detecttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW(),
    UNIQUE (uuid,address)
);
CREATE INDEX domain_idx_md5 ON domain (md5);
CREATE INDEX domain_idx_sha1 ON domain (sha1);

CREATE TABLE domain_whitelist() INHERITS (domain);
ALTER TABLE domain_whitelist ADD PRIMARY KEY (id);
ALTER TABLE domain_whitelist ADD CONSTRAINT domain_whitelist_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE domain_whitelist ADD UNIQUE(uuid,address);
create index domain_whitelist_idx_md5 on domain_whitelist (md5);
create index domain_whitelist_idx_sha1 on domain_whitelist (sha1);

CREATE TABLE domain_fastflux() INHERITS (domain);
ALTER TABLE domain_fastflux ADD PRIMARY KEY (id);
ALTER TABLE domain_fastflux ADD CONSTRAINT domain_fastflux_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE domain_fastflux ADD UNIQUE(uuid,address);
create index domain_fastflux_idx_md5 on domain_fastflux (md5);
create index domain_fastflux_idx_sha1 on domain_fastflux (sha1);

CREATE TABLE domain_nameserver() INHERITS (domain);
ALTER TABLE domain_nameserver ADD PRIMARY KEY (id);
ALTER TABLE domain_nameserver ADD CONSTRAINT domain_nameserver_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE domain_nameserver ADD UNIQUE(uuid,address);
create index domain_nameserver_idx_md5 on domain_nameserver (md5);
create index domain_nameserver_idx_sha1 on domain_nameserver (sha1);

CREATE TABLE domain_malware() INHERITS (domain);
ALTER TABLE domain_malware ADD PRIMARY KEY (id);
ALTER TABLE domain_malware ADD CONSTRAINT domain_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE domain_malware ADD UNIQUE(uuid,address);
create index domain_malware_idx_md5 on domain_malware (md5);
create index domain_malware_idx_sha1 on domain_malware (sha1);

CREATE TABLE domain_botnet() INHERITS (domain);
ALTER TABLE domain_botnet ADD PRIMARY KEY (id);
ALTER TABLE domain_botnet ADD CONSTRAINT domain_botnet_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE domain_botnet ADD UNIQUE(uuid,address);
create index domain_botnet_idx_md5 on domain_botnet (md5);
create index domain_botnet_idx_sha1 on domain_botnet (sha1);

CREATE TABLE domain_passivedns() INHERITS (domain);
ALTER TABLE domain_passivedns ADD PRIMARY KEY (id);
ALTER TABLE domain_passivedns ADD CONSTRAINT domain_passivedns_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE domain_passivedns ADD UNIQUE(uuid,address);
create index domain_passivedns_idx_md5 on domain_passivedns (md5);
create index domain_passivedns_idx_sha1 on domain_passivedns (sha1);

CREATE TABLE domain_search() INHERITS (domain);
ALTER TABLE domain_search ADD PRIMARY KEY (id);
ALTER TABLE domain_search ADD CONSTRAINT domain_search_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE domain_search ADD UNIQUE(uuid,address);
create index domain_search_idx_md5 on domain_search (md5);
create index domain_search_idx_sha1 on domain_search (sha1);

CREATE TABLE domain_phishing() INHERITS (domain);
ALTER TABLE domain_phishing ADD PRIMARY KEY (id);
ALTER TABLE domain_phishing ADD CONSTRAINT domain_phishing_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE domain_phishing ADD UNIQUE(uuid,address);
create index domain_phishing_idx_md5 on domain_phishing (md5);
create index domain_phishing_idx_sha1 on domain_phishing (sha1);

CREATE TABLE domain_suspicious() INHERITS (domain);
ALTER TABLE domain_suspicious ADD PRIMARY KEY (id);
ALTER TABLE domain_suspicious ADD CONSTRAINT domain_suspicious_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE domain_suspicious ADD UNIQUE(uuid,address);
create index domain_suspicious_idx_md5 on domain_phishing (md5);
create index domain_suspicious_idx_sha1 on domain_phishing (sha1);
