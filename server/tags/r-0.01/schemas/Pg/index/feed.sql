set default_tablespace = 'index';

DROP INDEX IF EXISTS idx_feed_feed_search;
CREATE INDEX idx_feed_feed_search ON feed_search (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
