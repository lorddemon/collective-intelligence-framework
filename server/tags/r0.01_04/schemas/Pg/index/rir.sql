set default_tablespace = 'index';

DROP INDEX IF EXISTS idx_feed_rir;
DROP INDEX IF EXISTS idx_query_rir;
DROP INDEX IF EXISTS idx_created_rir;
CREATE INDEX idx_feed_rir ON rir (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_rir ON rir (rir, detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_created_rir ON rir (created);
