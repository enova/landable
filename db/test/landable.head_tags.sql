BEGIN;

  SELECT plan(3);

  SELECT col_is_pk('landable', 'head_tags', 'head_tag_id', $$head_tag_id is PK.$$);
  SELECT col_is_fk('landable', 'head_tags', 'page_id', $$page_id is FK.$$);
  SELECT columns_are('landable', 'head_tags', ARRAY['head_tag_id','page_id','content','created_at','updated_at'], $$head_tags columns are correct.$$);

  SELECT finish();

ROLLBACK;
