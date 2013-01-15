-- Table: "user"

-- DROP TABLE "user";

CREATE TABLE "user"
(
  id serial NOT NULL,
  email character varying,
  name character varying,
  code character varying,
  last_logon timestamp without time zone,
  created_on timestamp without time zone,
  created_by character varying,
  active integer,
  timezone character varying,
  language character varying,
  theme character varying,
  path character varying,
  CONSTRAINT user_pkey PRIMARY KEY (id )
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "user"
  OWNER TO tagsobe;
