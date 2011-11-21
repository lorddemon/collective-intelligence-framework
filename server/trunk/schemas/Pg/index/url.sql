set default_tablespace = 'index';

DROP INDEX IF EXISTS idx_feed_url_botnet; 
CREATE INDEX idx_feed_url_botnet ON url_botnet (detecttime DESC, severity DESC, confidence DESC, restriction DESC);

DROP INDEX IF EXISTS idx_feed_url_malware;
CREATE INDEX idx_feed_url_malware ON url_malware (detecttime DESC, severity DESC, confidence DESC, restriction DESC);

DROP INDEX IF EXISTS idx_feed_url_phishing;
CREATE INDEX idx_feed_url_phishing ON url_phishing (detecttime DESC, severity DESC, confidence DESC, restriction DESC);

DROP INDEX IF EXISTS idx_feed_url_search;
CREATE INDEX idx_feed_url_search ON url_search (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
