BEGIN;

  SELECT PLAN(6);

  SELECT col_is_pk('landable', 'page_assets', 'page_asset_id', 'page_asset_id is pk');

  SELECT col_not_null('landable', 'page_assets', 'asset_id', 'asset_id is not null');
  SELECT col_not_null('landable', 'page_assets', 'page_id', 'page_id is not null');

  SELECT col_is_fk('landable', 'page_assets', 'asset_id', 'asset_id foreign keys');
  SELECT col_is_fk('landable', 'page_assets', 'page_id', 'page_id foreign keys');
  SELECT indexes_are('landable', 'page_assets', ARRAY['page_assets_pkey', 'landable_page_assets__u_page_id_asset_id'], 'Has indexes');

  SELECT * FROM finish();

ROLLBACK;
