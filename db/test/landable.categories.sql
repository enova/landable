BEGIN;

  SELECT PLAN(2);

  SELECT col_is_pk('landable', 'categories', 'category_id', 'Category_id is pk');

  select indexes_are('landable', 'categories', ARRAY['landable_categories__u_name', 'categories_pkey'], 'Has indexes');

  SELECT * FROM finish();

ROLLBACK;
