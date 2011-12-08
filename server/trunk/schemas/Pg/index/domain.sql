SET default_tablespace = 'index';

DROP INDEX IF EXISTS idx_feed_domain_fastflux;
DROP INDEX IF EXISTS idx_query_domain_fastflux;
DROP INDEX IF EXISTS idx_created_domain_fastflux;
CREATE INDEX idx_feed_domain_fastflux ON domain_fastflux (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_domain_fastflux ON domain_fastflux (md5, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_domain_fastflux ON domain_fastflux (created);

DROP INDEX IF EXISTS idx_feed_domain_nameserver;
DROP INDEX IF EXISTS idx_query_domain_nameserver;
DROP INDEX IF EXISTS idx_created_domain_nameserver;
CREATE INDEX idx_feed_domain_nameserver ON domain_nameserver (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_domain_nameserver ON domain_nameserver (md5, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_domain_nameserver ON domain_nameserver (created);

DROP INDEX IF EXISTS idx_feed_domain_malware;
DROP INDEX IF EXISTS idx_query_domain_malware;
DROP INDEX IF EXISTS idx_created_domain_malware;
CREATE INDEX idx_feed_domain_malware ON domain_malware (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_domain_malware ON domain_malware (md5, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_domain_malware ON domain_malware (created);

DROP INDEX IF EXISTS idx_feed_domain_botnet;
DROP INDEX IF EXISTS idx_query_domain_botnet;
DROP INDEX IF EXISTS idx_created_domain_botnet;
CREATE INDEX idx_feed_domain_botnet ON domain_botnet (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_domain_botnet ON domain_botnet (md5, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_domain_botnet ON domain_botnet (created);

DROP INDEX IF EXISTS idx_feed_domain_passivedns;
DROP INDEX IF EXISTS idx_query_domain_passivedns;
DROP INDEX IF EXISTS idx_created_domain_passivedns;
CREATE INDEX idx_feed_domain_passivedns ON domain_passivedns (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_domain_passivedns ON domain_passivedns (md5, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_domain_passivedns ON domain_passivedns (created);

DROP INDEX IF EXISTS idx_feed_domain_search;
DROP INDEX IF EXISTS idx_query_domain_search;
DROP INDEX IF EXISTS idx_created_domain_search;
CREATE INDEX idx_feed_domain_search ON domain_search (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_domain_search ON domain_search (md5, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_domain_search ON domain_search (created);

DROP INDEX IF EXISTS idx_feed_domain_phishing;
DROP INDEX IF EXISTS idx_query_domain_phishing;
DROP INDEX IF EXISTS idx_created_domain_phishing;
CREATE INDEX idx_feed_domain_phishing ON domain_phishing (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_domain_phishing ON domain_phishing (md5, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_domain_phishing ON domain_phishing (created);

DROP INDEX IF EXISTS idx_feed_domain_suspicious;
DROP INDEX IF EXISTS idx_query_domain_suspicious;
DROP INDEX IF EXISTS idx_created_domain_suspicious;
CREATE INDEX idx_feed_domain_suspicious ON domain_suspicious (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_domain_suspicious ON domain_suspicious (md5, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_domain_suspicious ON domain_suspicious (created);

DROP INDEX IF EXISTS idx_feed_domain_whitelist;
DROP INDEX IF EXISTS idx_query_domain_whitelist;
DROP INDEX IF EXISTS idx_created_domain_whitelist;
CREATE INDEX idx_feed_domain_whitelist ON domain_whitelist (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_domain_whitelist ON domain_whitelist (md5, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_domain_whitelist ON domain_whitelist (created);
