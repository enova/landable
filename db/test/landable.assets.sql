BEGIN;

  SELECT PLAN(8);

  SELECT col_is_pk('landable', 'assets', 'asset_id', 'Asset_id is pk');
  SELECT col_is_fk('landable', 'assets', 'author_id', 'author_id is fk');

  SELECT col_not_null('landable', 'assets', 'author_id', 'author_id not null');
  SELECT col_not_null('landable', 'assets', 'name', 'name not null');
  SELECT col_not_null('landable', 'assets', 'data', 'data not null');
  SELECT col_not_null('landable', 'assets', 'md5sum', 'md5sum not null');
  SELECT col_not_null('landable', 'assets', 'mime_type', 'mime_type not null');

  SELECT indexes_are('landable', 'assets', ARRAY['assets_pkey', 'landable_assets__u_data', 'landable_assets__u_md5sum', 'landable_assets__author_id', 'landable_assets__u_lower_name'], 'Assets has indexes');

  SELECT * FROM finish();

ROLLBACK;
