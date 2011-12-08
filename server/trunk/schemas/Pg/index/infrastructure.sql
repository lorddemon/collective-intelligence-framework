SET default_tablespace = 'index';

DROP INDEX IF EXISTS idx_feed_infrastructure_botnet;
DROP INDEX IF EXISTS idx_query_infrastructure_botnet;
DROP INDEX IF EXISTS idx_created_infrastructure_botnet;
CREATE INDEX idx_feed_infrastructure_botnet ON infrastructure_botnet (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_infrastructure_botnet ON infrastructure_botnet (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_infrastructure_botnet ON infrastructure_botnet (created);

DROP INDEX IF EXISTS idx_feed_infrastructure_malware;
DROP INDEX IF EXISTS idx_query_infrastructure_malware;
DROP INDEX IF EXISTS idx_created_infrastructure_malware;
CREATE INDEX idx_feed_infrastructure_malware ON infrastructure_malware (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_infrastructure_malware ON infrastructure_malware (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_infrastructure_malware ON infrastructure_malware (created);

DROP INDEX IF EXISTS idx_feed_infrastructure_whitelist;
DROP INDEX IF EXISTS idx_query_infrastructure_whitelist;
DROP INDEX IF EXISTS idx_created_infrastructure_whitelist;
CREATE INDEX idx_feed_infrastructure_whitelist ON infrastructure_whitelist (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_infrastructure_whitelist ON infrastructure_whitelist (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_infrastructure_whitelist ON infrastructure_whitelist (created);

DROP INDEX IF EXISTS idx_feed_infrastructure_scan;
DROP INDEX IF EXISTS idx_query_infrastructure_scan;
DROP INDEX IF EXISTS idx_created_infrastructure_scan;
CREATE INDEX idx_feed_infrastructure_scan ON infrastructure_scan (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_infrastructure_scan ON infrastructure_scan (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_infrastructure_scan ON infrastructure_scan (created);

DROP INDEX IF EXISTS idx_feed_infrastructure_spam;
DROP INDEX IF EXISTS idx_query_infrastructure_spam;
DROP INDEX IF EXISTS idx_created_infrastructure_spam;
CREATE INDEX idx_feed_infrastructure_spam ON infrastructure_spam (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_infrastructure_spam ON infrastructure_spam (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_infrastructure_spam ON infrastructure_spam (created);

DROP INDEX IF EXISTS idx_feed_infrastructure_network;
DROP INDEX IF EXISTS idx_query_infrastructure_network;
DROP INDEX IF EXISTS idx_created_infrastructure_network;
CREATE INDEX idx_feed_infrastructure_network ON infrastructure_network (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_infrastructure_network ON infrastructure_network (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_infrastructure_network ON infrastructure_network (created);

DROP INDEX IF EXISTS idx_feed_infrastructure_suspicious;
DROP INDEX IF EXISTS idx_query_infrastructure_suspicious;
DROP INDEX IF EXISTS idx_created_infrastructure_suspicious;
CREATE INDEX idx_feed_infrastructure_suspicious ON infrastructure_suspicious (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_infrastructure_suspicious ON infrastructure_suspicious (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_infrastructure_suspicious ON infrastructure_suspicious (created);

DROP INDEX IF EXISTS idx_feed_infrastructure_phishing;
DROP INDEX IF EXISTS idx_query_infrastructure_phishing;
DROP INDEX IF EXISTS idx_created_infrastructure_phishing;
CREATE INDEX idx_feed_infrastructure_phishing ON infrastructure_phishing (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_infrastructure_phishing ON infrastructure_phishing (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_infrastructure_phishing ON infrastructure_phishing (created);

DROP INDEX IF EXISTS idx_feed_infrastructure_search;
DROP INDEX IF EXISTS idx_query_infrastructure_search;
DROP INDEX IF EXISTS idx_created_infrastructure_search;
CREATE INDEX idx_feed_infrastructure_search ON infrastructure_search (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_infrastructure_search ON infrastructure_search (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_infrastructure_search ON infrastructure_search (created);

DROP INDEX IF EXISTS idx_feed_infrastructure_passivedns;
DROP INDEX IF EXISTS idx_query_infrastructure_passivedns;
DROP INDEX IF EXISTS idx_created_infrastructure_passivedns;
CREATE INDEX idx_feed_infrastructure_passivedns ON infrastructure_passivedns (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_infrastructure_passivedns ON infrastructure_passivedns (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_infrastructure_passivedns ON infrastructure_passivedns (created);

DROP INDEX IF EXISTS idx_feed_infrastructure_warez;
DROP INDEX IF EXISTS idx_query_infrastructure_warez;
DROP INDEX IF EXISTS idx_created_infrastructure_warez;
CREATE INDEX idx_feed_infrastructure_warez ON infrastructure_warez (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_infrastructure_warez ON infrastructure_warez (address, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_infrastructure_warez ON infrastructure_warez (created);
