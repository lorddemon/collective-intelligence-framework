DROP TABLE IF EXISTS message CASCADE;
CREATE TYPE severity AS ENUM ('low','medium','high');
CREATE TYPE restriction AS ENUM ('public','need-to-know','private','default');

CREATE TABLE message (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid NOT NULL,
    source uuid,
    format text, -- IODEF, MetaSharing, IRC, Email, etc...
    description text,
    restriction restriction default 'private',
    created timestamp with time zone DEFAULT NOW(),
    message text not null,
    UNIQUE (uuid)
);

-- unclear if we really need this for xpath queries or not

-- DROP TABLE IF EXISTS message_xml CASCADE;
-- CREATE TABLE message_xml (
--    id bigserial primary key not null,
--   uuid uuid references message(uuid) on delete cascade,
--    source uuid,
--    format text,
--    description text,
--    restriction restriction default 'private',
--   message xml,
--    detecttime timestamp with time zone default now(),
--    created timestamp with time zone default now(),
--    UNIQUE(uuid)
--);
