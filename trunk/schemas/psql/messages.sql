DROP VIEW v_messages;
DROP TABLE messages_structured;
DROP TABLE messages_unstructured;
DROP TABLE messages;
CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid NOT NULL,
    source uuid NOT NULL,
    type VARCHAR(16) CHECK (type IN ('structured','unstructured')) DEFAULT 'unstructured' NOT NULL,
    format VARCHAR(32), -- IODEF, MetaSharing, IRC, Email, etc...
    confidence REAL,
    severity VARCHAR(6) CHECK (severity IN ('low','medium','high')),
    description text,
    impact VARCHAR(140),
    restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    detecttime timestamp with time zone,
    created timestamp with time zone DEFAULT NOW(),
    UNIQUE (uuid)
);

CREATE TABLE messages_structured (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES messages (uuid) ON DELETE CASCADE NOT NULL,
    source uuid NOT NULL,
    message xml,
    UNIQUE(uuid)
);

CREATE TABLE messages_unstructured (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES messages (uuid) ON DELETE CASCADE NOT NULL,
    source uuid NOT NULL,
    message text NOT NULL,
    tsv tsvector,
    UNIQUE(uuid)
);

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE
ON messages_unstructured FOR EACH ROW EXECUTE PROCEDURE
tsvector_update_trigger(tsv, 'pg_catalog.english', message);

CREATE VIEW v_messages AS
SELECT messages.*,messages_unstructured.message as unstructured, messages_structured.message as structured, messages_unstructured.tsv
FROM messages 
LEFT JOIN messages_unstructured ON (messages_unstructured.uuid = messages.uuid AND messages_unstructured.source = messages.source)
LEFT JOIN messages_structured ON (messages_structured.uuid = messages.uuid AND messages_structured.source = messages.source);
