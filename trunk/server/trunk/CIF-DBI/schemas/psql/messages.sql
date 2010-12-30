DROP VIEW IF EXISTS v_messages;
DROP TABLE IF EXISTS messages_structured;
DROP TABLE IF EXISTS messages_unstructured;
DROP TABLE IF EXISTS messages_blob;
DROP TABLE IF EXISTS messages;

CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid NOT NULL,
    source uuid NOT NULL,
    type VARCHAR(16) not null,
    format VARCHAR(32), -- IODEF, MetaSharing, IRC, Email, etc...
    confidence REAL,
    severity VARCHAR(6) CHECK (severity IN ('low','medium','high')),
    description text,
    impact VARCHAR(140),
    restriction VARCHAR(16) CHECK (restriction IN ('default','private','need-to-know','public')) DEFAULT 'private' NOT NULL,
    detecttime timestamp with time zone DEFAULT NOW(),
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
    UNIQUE(uuid)
);

CREATE TABLE messages_blob (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid references messages(uuid) on delete cascade not null,
    message bytea not null,
    unique(uuid)
);

CREATE VIEW v_messages AS
SELECT messages.*,messages_unstructured.message as unstructured, messages_structured.message as structured
FROM messages 
LEFT JOIN messages_unstructured ON (messages_unstructured.uuid = messages.uuid AND messages_unstructured.source = messages.source)
LEFT JOIN messages_structured ON (messages_structured.uuid = messages.uuid AND messages_structured.source = messages.source);
