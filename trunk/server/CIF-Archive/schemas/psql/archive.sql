DROP TABLE IF EXISTS archive CASCADE;
CREATE TYPE restriction AS ENUM ('public','need-to-know','private','default');

CREATE TABLE archive (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid NOT NULL,
    source uuid,
    format text, -- IODEF, MetaSharing, IRC, Email, etc...
    description text,
    restriction restriction default 'private',
    created timestamp with time zone DEFAULT NOW(),
    data text not null,
    UNIQUE (uuid)
);
