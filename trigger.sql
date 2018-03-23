CREATE OR REPLACE FUNCTION audit_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF (TG_OP = 'UPDATE') THEN
    INSERT INTO changes (table_name, operation, old_content, new_content, created_at)
      VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD), row_to_json(NEW), now());
    RETURN NEW;
  END IF;
END;
$$;

drop table if exists changes;
create table changes (
  table_name varchar,
  operation varchar,
  old_content jsonb,
  new_content jsonb,
  created_at timestamp
);

drop table if exists items;
create table items (
  name varchar,
  type varchar
);

CREATE TRIGGER audit_items_changes BEFORE UPDATE ON items FOR EACH ROW EXECUTE PROCEDURE audit_changes();

INSERT INTO items
  (name, type)
VALUES
  ('Apple', 'Fruit'),
  ('Wine', 'Drink'),
  ('Beer', 'Drink'),
  ('Chocolate', 'Food')
;

SELECT * FROM items;

UPDATE items SET name = 'Orange' WHERE name = 'Apple';

SELECT * FROM changes;
