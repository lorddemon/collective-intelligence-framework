DROP TABLE IF EXISTS hash CASCADE;
CREATE TABLE hash (
    id BIGSERIAL PRIMARY KEY NOT NULL,
    uuid uuid REFERENCES archive(uuid) ON DELETE CASCADE NOT NULL,
    hash text not null,
    source uuid,
    type text,
    severity severity,
    confidence real,
    restriction restriction not null default 'private',
    detecttime timestamp with time zone DEFAULT NOW(),
    created timestamp with time zone DEFAULT NOW(),
    unique(uuid,hash)
);

CREATE TABLE hash_md5 () INHERITS (hash);
ALTER TABLE hash_md5 ADD PRIMARY KEY (id);
ALTER TABLE hash_md5 ADD CONSTRAINT hash_md5_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE hash_md5 ADD UNIQUE(uuid);
ALTER TABLE hash_md5 ALTER COLUMN type SET DEFAULT 'md5';

CREATE TABLE hash_sha1 () INHERITS (hash);
ALTER TABLE hash_sha1 ADD PRIMARY KEY (id);
ALTER TABLE hash_sha1 ADD CONSTRAINT hash_sha1_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE hash_sha1 ADD UNIQUE(uuid);
ALTER TABLE hash_sha1 ALTER COLUMN type SET DEFAULT 'sha1';

CREATE TABLE hash_uuid () INHERITS (hash);
ALTER TABLE hash_uuid ADD PRIMARY KEY (id);
ALTER TABLE hash_uuid ADD CONSTRAINT hash_uuid_uuid_fkey FOREIGN KEY (uuid) REFERENCES archive(uuid) ON DELETE CASCADE;
ALTER TABLE hash_uuid ADD UNIQUE(uuid);
ALTER TABLE hash_uuid ALTER COLUMN type SET DEFAULT 'uuid';
