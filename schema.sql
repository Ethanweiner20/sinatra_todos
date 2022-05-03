/* Todos Database Schema */

CREATE TABLE lists
(
  id serial PRIMARY KEY,
  name text NOT NULL UNIQUE
);

CREATE TABLE todos
(
  id SERIAL PRIMARY KEY,
  name text NOT NULL,
  is_completed boolean NOT NULL DEFAULT false,
  list_id integer NOT NULL REFERENCES lists(id)
);