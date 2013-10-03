BEGIN;

  SELECT PLAN(12);

  SELECT col_is_pk('landable', 'themes', 'theme_id', 'Theme_id is PK');

  SELECT col_not_null('landable', 'themes', 'name', 'Name is not null');
  SELECT col_not_null('landable', 'themes', 'body', 'body is not null');
  SELECT col_not_null('landable', 'themes', 'description', 'Description is not null');
  SELECT col_not_null('landable', 'themes', 'editable', 'Editable is not null');

  SELECT col_has_default('landable', 'themes', 'editable', $$Editable has default.$$);

  --Verify unique index on theme name
  SELECT lives_ok($$INSERT INTO landable.themes (name, body, description, editable) VALUES ('test', 'body', 'test body', true)$$);
  SELECT throws_matching($$INSERT INTO landable.themes (name, body, description) VALUES ('test', 'body', 'test body')$$, 'name');
  SELECT throws_matching($$INSERT INTO landable.themes (name, body, description) VALUES ('TEST', 'body', 'test body')$$, 'name');

  SELECT index_is_unique('landable', 'themes', 'landable_themes__u_file', $$Unique index on file column.$$);
  SELECT lives_ok($$INSERT INTO landable.themes (file, name, body, description, editable) VALUES ('filename', 'test1', 'body', 'test body', true)$$);
  SELECT throws_matching($$INSERT INTO landable.themes (file, name, body, description) VALUES ('FILENAME', 'test1', 'body', 'test body')$$, '__u_file');

  SELECT * FROM finish();

ROLLBACK;
