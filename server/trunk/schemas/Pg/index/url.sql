set default_tablespace = 'index';

DROP INDEX IF EXISTS idx_feed_url_botnet; 
DROP INDEX IF EXISTS idx_created_url_botnet;
CREATE INDEX idx_feed_url_botnet ON url_botnet (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_url_botnet ON url_botnet (created);

DROP INDEX IF EXISTS idx_feed_url_malware;
DROP INDEX IF EXISTS idx_created_url_malware;
CREATE INDEX idx_feed_url_malware ON url_malware (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_url_malware ON url_malware (created);

DROP INDEX IF EXISTS idx_feed_url_phishing;
DROP INDEX IF EXISTS idx_created_url_phishing;
CREATE INDEX idx_feed_url_phishing ON url_phishing (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_url_phishing ON url_phishing (created);

DROP INDEX IF EXISTS idx_feed_url_search;
DROP INDEX IF EXISTS idx_created_url_search;
CREATE INDEX idx_feed_url_search ON url_search (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_url_search ON url_search (created);
