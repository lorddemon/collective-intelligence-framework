DROP TABLE IF EXISTS analytic CASCADE;
CREATE TABLE analytic (
    id bigserial primary key not null,
    uuid uuid not null references archive(uuid) on delete cascade not null,
    description text,
    startid bigint,
    endid bigint,
    source uuid,
    created timestamp with time zone default NOW(),
    unique(uuid)
);
