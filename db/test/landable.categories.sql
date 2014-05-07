BEGIN;

  SELECT PLAN(1);

  SELECT col_is_pk('dummy_landable', 'categories', 'category_id', 'Category_id is pk');

  SELECT * FROM finish();

ROLLBACK;
