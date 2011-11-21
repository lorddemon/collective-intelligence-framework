set default_tablespace = 'index';

DROP INDEX IF EXISTS idx_feed_asn;
DROP INDEX IF EXISTS idx_query_asn;
CREATE INDEX idx_feed_asn ON asn (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_asn ON asn (asn, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
