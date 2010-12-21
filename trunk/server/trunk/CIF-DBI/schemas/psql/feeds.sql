DROP TABLE IF EXISTS feeds CASCADE;
CREATE TABLE feeds (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid NOT NULL REFERENCES messages(uuid) ON DELETE CASCADE,
    description text default 'feed',
    source uuid,
    hash_sha1 varchar(40),
    signature text,
    impact VARCHAR(140) default 'feed',
    severity VARCHAR(6) CHECK (severity IN ('low','medium','high')),
    restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    created timestamp with time zone DEFAULT NOW(),
    message bytea not null,
    UNIQUE (uuid)
);

CREATE TABLE feeds_infrastructure () INHERITS (feeds);
ALTER TABLE feeds_infrastructure ADD PRIMARY KEY (id);
ALTER TABLE feeds_infrastructure ADD CONSTRAINT feeds_infrastructure_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_infrastructure ADD UNIQUE(uuid);

CREATE TABLE feeds_infrastructure_botnet () INHERITS (feeds);
ALTER TABLE feeds_infrastructure_botnet ADD PRIMARY KEY (id);
ALTER TABLE feeds_infrastructure_botnet ADD CONSTRAINT feeds_infrastructure_botnet_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_infrastructure_botnet ADD UNIQUE(uuid);

CREATE TABLE feeds_infrastructure_malware () INHERITS (feeds);
ALTER TABLE feeds_infrastructure_malware ADD PRIMARY KEY (id);
ALTER TABLE feeds_infrastructure_malware ADD CONSTRAINT feeds_infrastructure_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_infrastructure_malware ADD UNIQUE(uuid);

CREATE TABLE feeds_infrastructure_network () INHERITS (feeds);
ALTER TABLE feeds_infrastructure_network ADD PRIMARY KEY (id);
ALTER TABLE feeds_infrastructure_network ADD CONSTRAINT feeds_infrastructure_network_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_infrastructure_network ADD UNIQUE(uuid);

CREATE TABLE feeds_infrastructure_phishing () INHERITS (feeds);
ALTER TABLE feeds_infrastructure_phishing ADD PRIMARY KEY (id);
ALTER TABLE feeds_infrastructure_phishing ADD CONSTRAINT feeds_infrastructure_phishing_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_infrastructure_phishing ADD UNIQUE(uuid);

CREATE TABLE feeds_infrastructure_spam () INHERITS (feeds);
ALTER TABLE feeds_infrastructure_spam ADD PRIMARY KEY (id);
ALTER TABLE feeds_infrastructure_spam ADD CONSTRAINT feeds_infrastructure_spam_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_infrastructure_spam ADD UNIQUE(uuid);

CREATE TABLE feeds_infrastructure_scan () INHERITS (feeds);
ALTER TABLE feeds_infrastructure_scan ADD PRIMARY KEY (id);
ALTER TABLE feeds_infrastructure_scan ADD CONSTRAINT feeds_infrastructure_scan_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_infrastructure_scan ADD UNIQUE(uuid);

CREATE TABLE feeds_infrastructure_suspicious () INHERITS (feeds);
ALTER TABLE feeds_infrastructure_suspicious ADD PRIMARY KEY (id);
ALTER TABLE feeds_infrastructure_suspicious ADD CONSTRAINT feeds_infrastructure_suspicious_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_infrastructure_suspicious ADD UNIQUE(uuid);

CREATE TABLE feeds_infrastructure_whitelist () INHERITS (feeds);
ALTER TABLE feeds_infrastructure_whitelist ADD PRIMARY KEY (id);
ALTER TABLE feeds_infrastructure_whitelist ADD CONSTRAINT feeds_infrastructure_whitelist_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_infrastructure_whitelist ADD UNIQUE(uuid);

CREATE TABLE feeds_domains () INHERITS (feeds);
ALTER TABLE feeds_domains ADD PRIMARY KEY (id);
ALTER TABLE feeds_domains ADD CONSTRAINT feeds_domains_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_domains ADD UNIQUE(uuid);

CREATE TABLE feeds_domains_botnet () INHERITS (feeds);
ALTER TABLE feeds_domains_botnet ADD PRIMARY KEY (id);
ALTER TABLE feeds_domains_botnet ADD CONSTRAINT feeds_domains_botnet_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_domains_botnet ADD UNIQUE(uuid);

CREATE TABLE feeds_domains_malware () INHERITS (feeds);
ALTER TABLE feeds_domains_malware ADD PRIMARY KEY (id);
ALTER TABLE feeds_domains_malware ADD CONSTRAINT feeds_domains_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_domains_malware ADD UNIQUE(uuid);

CREATE TABLE feeds_domains_nameservers () INHERITS (feeds);
ALTER TABLE feeds_domains_nameservers ADD PRIMARY KEY (id);
ALTER TABLE feeds_domains_nameservers ADD CONSTRAINT feeds_domains_nameservers_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_domains_nameservers ADD UNIQUE(uuid);

CREATE TABLE feeds_domains_whitelist () INHERITS (feeds);
ALTER TABLE feeds_domains_whitelist ADD PRIMARY KEY (id);
ALTER TABLE feeds_domains_whitelist ADD CONSTRAINT feeds_domains_whitelist_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_domains_whitelist ADD UNIQUE(uuid);

CREATE TABLE feeds_urls () INHERITS (feeds);
ALTER TABLE feeds_urls ADD PRIMARY KEY (id);
ALTER TABLE feeds_urls ADD CONSTRAINT feeds_urls_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_urls ADD UNIQUE(uuid);

CREATE TABLE feeds_urls_malware () INHERITS (feeds);
ALTER TABLE feeds_urls_malware ADD PRIMARY KEY (id);
ALTER TABLE feeds_urls_malware ADD CONSTRAINT feeds_urls_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_urls_malware ADD UNIQUE(uuid);

CREATE TABLE feeds_urls_botnet () INHERITS (feeds);
ALTER TABLE feeds_urls_botnet ADD PRIMARY KEY (id);
ALTER TABLE feeds_urls_botnet ADD CONSTRAINT feeds_urls_botnet_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_urls_botnet ADD UNIQUE(uuid);

CREATE TABLE feeds_urls_phishing () INHERITS (feeds);
ALTER TABLE feeds_urls_phishing ADD PRIMARY KEY (id);
ALTER TABLE feeds_urls_phishing ADD CONSTRAINT feeds_urls_phishing_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_urls_phishing ADD UNIQUE(uuid);

CREATE TABLE feeds_malware () INHERITS (feeds);
ALTER TABLE feeds_malware ADD PRIMARY KEY (id);
ALTER TABLE feeds_malware ADD CONSTRAINT feeds_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES messages(uuid) ON DELETE CASCADE;
ALTER TABLE feeds_malware ADD UNIQUE(uuid);

