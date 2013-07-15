BEGIN;

  SELECT PLAN(7);

  SELECT col_is_pk('landable', 'themes', 'theme_id', 'Theme_id is PK');

  SELECT col_not_null('landable', 'themes', 'name', 'Name is not null');
  SELECT col_not_null('landable', 'themes', 'body', 'body is not null');
  SELECT col_not_null('landable', 'themes', 'description', 'Description is not null');

  --Verify unique index on theme name
  SELECT lives_ok($$INSERT INTO landable.themes (name, body, description) VALUES ('test', 'body', 'test body')$$);
  SELECT throws_matching($$INSERT INTO landable.themes (name, body, description) VALUES ('test', 'body', 'test body')$$, 'name');
  SELECT throws_matching($$INSERT INTO landable.themes (name, body, description) VALUES ('TEST', 'body', 'test body')$$, 'name');

  SELECT * FROM finish();

ROLLBACK;
