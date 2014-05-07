BEGIN;

  SELECT PLAN(7);

  SELECT col_is_pk('dummy_landable', 'assets', 'asset_id', 'Asset_id is pk');
  SELECT col_is_fk('dummy_landable', 'assets', 'author_id', 'author_id is fk');

  SELECT col_not_null('dummy_landable', 'assets', 'author_id', 'author_id not null');
  SELECT col_not_null('dummy_landable', 'assets', 'name', 'name not null');
  SELECT col_not_null('dummy_landable', 'assets', 'data', 'data not null');
  SELECT col_not_null('dummy_landable', 'assets', 'md5sum', 'md5sum not null');
  SELECT col_not_null('dummy_landable', 'assets', 'mime_type', 'mime_type not null');

  SELECT * FROM finish();

ROLLBACK;
