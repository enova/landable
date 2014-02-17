BEGIN;

  SELECT PLAN(12);

  SELECT col_is_pk('dummy_landable', 'themes', 'theme_id', 'Theme_id is PK');

  SELECT col_not_null('dummy_landable', 'themes', 'name', 'Name is not null');
  SELECT col_not_null('dummy_landable', 'themes', 'body', 'body is not null');
  SELECT col_not_null('dummy_landable', 'themes', 'description', 'Description is not null');
  SELECT col_not_null('dummy_landable', 'themes', 'editable', 'Editable is not null');

  SELECT col_has_default('dummy_landable', 'themes', 'editable', $$Editable has default.$$);

  --Verify unique index on theme name
  SELECT lives_ok($$INSERT INTO dummy_landable.themes (name, body, description, editable) VALUES ('test', 'body', 'test body', true)$$);
  SELECT throws_matching($$INSERT INTO dummy_landable.themes (name, body, description) VALUES ('test', 'body', 'test body')$$, 'name');
  SELECT throws_matching($$INSERT INTO dummy_landable.themes (name, body, description) VALUES ('TEST', 'body', 'test body')$$, 'name');

  SELECT index_is_unique('dummy_landable', 'themes', 'dummy_landable_themes__u_file', $$Unique index on file column.$$);
  SELECT lives_ok($$INSERT INTO dummy_landable.themes (file, name, body, description, editable) VALUES ('filename', 'test1', 'body', 'test body', true)$$);
  SELECT throws_matching($$INSERT INTO dummy_landable.themes (file, name, body, description) VALUES ('FILENAME', 'test1', 'body', 'test body')$$, '__u_file');

  SELECT * FROM finish();

ROLLBACK;
