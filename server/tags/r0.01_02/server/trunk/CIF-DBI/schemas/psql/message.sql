DROP TABLE IF EXISTS message CASCADE;
CREATE TYPE severity AS ENUM ('low','medium','high');
CREATE TYPE restriction AS ENUM ('public','need-to-know','private','default');

CREATE TABLE message (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid NOT NULL,
    source uuid NOT NULL,
    type VARCHAR(16) not null,
    format VARCHAR(32), -- IODEF, MetaSharing, IRC, Email, etc...
    confidence REAL,
    severity severity,
    description text,
    impact VARCHAR(140),
    restriction restriction not null default 'private',
    detecttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW(),
    UNIQUE (uuid)
);

CREATE TABLE message_structured (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES message (uuid) ON DELETE CASCADE NOT NULL,
    source uuid NOT NULL,
    message xml,
    UNIQUE(uuid)
);

CREATE TABLE message_unstructured (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES message (uuid) ON DELETE CASCADE NOT NULL,
    source uuid NOT NULL,
    message text NOT NULL,
    UNIQUE(uuid)
);

CREATE VIEW v_message AS
SELECT message.*,message_unstructured.message as unstructured, message_structured.message as structured
FROM message 
LEFT JOIN message_unstructured ON (message_unstructured.uuid = message.uuid AND message_unstructured.source = message.source)
LEFT JOIN message_structured ON (message_structured.uuid = message.uuid AND message_structured.source = message.source);
