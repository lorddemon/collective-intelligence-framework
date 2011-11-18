set default_tablespace = 'index';

DROP INDEX IF EXISTS idx_feed_countrycode;
DROP INDEX IF EXISTS idx_query_countrycode;
CREATE INDEX idx_feed_countrycode ON countrycode (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_countrycode ON countrycode (cc);
