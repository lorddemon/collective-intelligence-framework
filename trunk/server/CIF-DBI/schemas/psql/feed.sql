DROP TABLE IF EXISTS feed CASCADE;
CREATE TABLE feed (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid NOT NULL REFERENCES message(uuid) ON DELETE CASCADE,
    description text default 'feed',
    source uuid,
    hash_sha1 varchar(40),
    signature text,
    impact VARCHAR(140) default 'feed',
    severity severity,
    restriction restriction not null default 'private',
    detecttime timestamp with time zone default NOW(),
    created timestamp with time zone DEFAULT NOW(),
    message text not null,
    UNIQUE (uuid)
);

create view v_feed as select id,uuid,restriction,severity,description,created from feed;

CREATE TABLE feed_infrastructure () INHERITS (feed);
ALTER TABLE feed_infrastructure ADD PRIMARY KEY (id);
ALTER TABLE feed_infrastructure ADD CONSTRAINT feed_infrastructure_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_infrastructure ADD UNIQUE(uuid);

CREATE TABLE feed_infrastructure_botnet () INHERITS (feed);
ALTER TABLE feed_infrastructure_botnet ADD PRIMARY KEY (id);
ALTER TABLE feed_infrastructure_botnet ADD CONSTRAINT feed_infrastructure_botnet_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_infrastructure_botnet ADD UNIQUE(uuid);

CREATE TABLE feed_infrastructure_malware () INHERITS (feed);
ALTER TABLE feed_infrastructure_malware ADD PRIMARY KEY (id);
ALTER TABLE feed_infrastructure_malware ADD CONSTRAINT feed_infrastructure_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_infrastructure_malware ADD UNIQUE(uuid);

CREATE TABLE feed_infrastructure_network () INHERITS (feed);
ALTER TABLE feed_infrastructure_network ADD PRIMARY KEY (id);
ALTER TABLE feed_infrastructure_network ADD CONSTRAINT feed_infrastructure_network_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_infrastructure_network ADD UNIQUE(uuid);

CREATE TABLE feed_infrastructure_phishing () INHERITS (feed);
ALTER TABLE feed_infrastructure_phishing ADD PRIMARY KEY (id);
ALTER TABLE feed_infrastructure_phishing ADD CONSTRAINT feed_infrastructure_phishing_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_infrastructure_phishing ADD UNIQUE(uuid);

CREATE TABLE feed_infrastructure_spam () INHERITS (feed);
ALTER TABLE feed_infrastructure_spam ADD PRIMARY KEY (id);
ALTER TABLE feed_infrastructure_spam ADD CONSTRAINT feed_infrastructure_spam_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_infrastructure_spam ADD UNIQUE(uuid);

CREATE TABLE feed_infrastructure_scan () INHERITS (feed);
ALTER TABLE feed_infrastructure_scan ADD PRIMARY KEY (id);
ALTER TABLE feed_infrastructure_scan ADD CONSTRAINT feed_infrastructure_scan_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_infrastructure_scan ADD UNIQUE(uuid);

CREATE TABLE feed_infrastructure_suspicious () INHERITS (feed);
ALTER TABLE feed_infrastructure_suspicious ADD PRIMARY KEY (id);
ALTER TABLE feed_infrastructure_suspicious ADD CONSTRAINT feed_infrastructure_suspicious_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_infrastructure_suspicious ADD UNIQUE(uuid);

CREATE TABLE feed_infrastructure_asn () INHERITS (feed);
ALTER TABLE feed_infrastructure_asn ADD PRIMARY KEY (id);
ALTER TABLE feed_infrastructure_asn ADD CONSTRAINT feed_infrastructure_asn_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_infrastructure_asn ADD UNIQUE(uuid);

CREATE TABLE feed_infrastructure_whitelist () INHERITS (feed);
ALTER TABLE feed_infrastructure_whitelist ADD PRIMARY KEY (id);
ALTER TABLE feed_infrastructure_whitelist ADD CONSTRAINT feed_infrastructure_whitelist_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_infrastructure_whitelist ADD UNIQUE(uuid);

CREATE TABLE feed_infrastructure_search () INHERITS (feed);
ALTER TABLE feed_infrastructure_search ADD PRIMARY KEY (id);
ALTER TABLE feed_infrastructure_search ADD CONSTRAINT feed_infrastructure_search_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_infrastructure_search ADD UNIQUE(uuid);

CREATE TABLE feed_domain () INHERITS (feed);
ALTER TABLE feed_domain ADD PRIMARY KEY (id);
ALTER TABLE feed_domain ADD CONSTRAINT feed_domain_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_domain ADD UNIQUE(uuid);

CREATE TABLE feed_domain_botnet () INHERITS (feed);
ALTER TABLE feed_domain_botnet ADD PRIMARY KEY (id);
ALTER TABLE feed_domain_botnet ADD CONSTRAINT feed_domain_botnet_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_domain_botnet ADD UNIQUE(uuid);

CREATE TABLE feed_domain_malware () INHERITS (feed);
ALTER TABLE feed_domain_malware ADD PRIMARY KEY (id);
ALTER TABLE feed_domain_malware ADD CONSTRAINT feed_domain_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_domain_malware ADD UNIQUE(uuid);

CREATE TABLE feed_domain_nameserver () INHERITS (feed);
ALTER TABLE feed_domain_nameserver ADD PRIMARY KEY (id);
ALTER TABLE feed_domain_nameserver ADD CONSTRAINT feed_domain_nameserver_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_domain_nameserver ADD UNIQUE(uuid);

CREATE TABLE feed_domain_fastflux () INHERITS (feed);
ALTER TABLE feed_domain_fastflux ADD PRIMARY KEY (id);
ALTER TABLE feed_domain_fastflux ADD CONSTRAINT feed_domain_fastflux_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_domain_fastflux ADD UNIQUE(uuid);

CREATE TABLE feed_domain_whitelist () INHERITS (feed);
ALTER TABLE feed_domain_whitelist ADD PRIMARY KEY (id);
ALTER TABLE feed_domain_whitelist ADD CONSTRAINT feed_domain_whitelist_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_domain_whitelist ADD UNIQUE(uuid);

CREATE TABLE feed_url () INHERITS (feed);
ALTER TABLE feed_url ADD PRIMARY KEY (id);
ALTER TABLE feed_url ADD CONSTRAINT feed_url_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_url ADD UNIQUE(uuid);

CREATE TABLE feed_url_malware () INHERITS (feed);
ALTER TABLE feed_url_malware ADD PRIMARY KEY (id);
ALTER TABLE feed_url_malware ADD CONSTRAINT feed_url_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_url_malware ADD UNIQUE(uuid);

CREATE TABLE feed_url_botnet () INHERITS (feed);
ALTER TABLE feed_url_botnet ADD PRIMARY KEY (id);
ALTER TABLE feed_url_botnet ADD CONSTRAINT feed_url_botnet_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_url_botnet ADD UNIQUE(uuid);

CREATE TABLE feed_url_phishing () INHERITS (feed);
ALTER TABLE feed_url_phishing ADD PRIMARY KEY (id);
ALTER TABLE feed_url_phishing ADD CONSTRAINT feed_url_phishing_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_url_phishing ADD UNIQUE(uuid);

CREATE TABLE feed_malware () INHERITS (feed);
ALTER TABLE feed_malware ADD PRIMARY KEY (id);
ALTER TABLE feed_malware ADD CONSTRAINT feed_malware_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_malware ADD UNIQUE(uuid);

CREATE TABLE feed_email () INHERITS (feed);
ALTER TABLE feed_email ADD PRIMARY KEY (id);
ALTER TABLE feed_email ADD CONSTRAINT feed_email_uuid_fkey FOREIGN KEY (uuid) REFERENCES message(uuid) ON DELETE CASCADE;
ALTER TABLE feed_email ADD UNIQUE(uuid);
