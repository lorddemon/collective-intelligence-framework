set default_tablespace = 'index';

DROP INDEX IF EXISTS idx_feed_email_search;
DROP INDEX IF EXISTS idx_query_email_search;
CREATE INDEX idx_feed_email_search ON email_search (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_email_search ON email_search (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);

DROP INDEX IF EXISTS idx_feed_email_phishing;
DROP INDEX IF EXISTS idx_query_email_phishing;
CREATE INDEX idx_feed_email_phishing ON email_phishing (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_email_phishing ON email_phishing (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);

DROP INDEX IF EXISTS idx_feed_email_registrant;
DROP INDEX IF EXISTS idx_query_email_registrant;
CREATE INDEX idx_feed_email_registrant ON email_registrant (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_email_registrant ON email_registrant (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
