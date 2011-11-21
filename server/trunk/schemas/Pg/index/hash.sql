SET default_tablespace = 'index';

DROP INDEX IF EXISTS idx_feed_hash_md5;
DROP INDEX IF EXISTS idx_query_hash_md5;
CREATE INDEX idx_feed_hash_md5 ON hash_md5 (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_hash_md5 ON hash_md5 (lower(hash), detecttime DESC, severity DESC, confidence DESC, restriction DESC);

DROP INDEX IF EXISTS idx_feed_hash_sha1;
DROP INDEX IF EXISTS idx_query_hash_sha1;
CREATE INDEX idx_feed_hash_sha1 ON hash_sha1 (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_hash_sha1 ON hash_sha1 (lower(hash), detecttime DESC, severity DESC, confidence DESC, restriction DESC);

DROP INDEX IF EXISTS idx_feed_hash_uuid;
DROP INDEX IF EXISTS idx_query_hash_uuid;
CREATE INDEX idx_feed_hash_uuid ON hash_uuid (detecttime DESC, severity DESC, confidence DESC, restriction DESC);
CREATE INDEX idx_query_hash_uuid ON hash_uuid (lower(hash), detecttime DESC, severity DESC, confidence DESC, restriction DESC);
