BEGIN;
SELECT PLAN(6);

SELECT col_not_null('landable', 'browsers', 'os', 'os not null');
SELECT col_not_null('landable', 'browsers', 'os_version', 'os_version not null');
SELECT col_not_null('landable', 'browsers', 'screenshots_supported', 'screenshots_supported not null');
SELECT col_not_null('landable', 'browsers', 'is_primary', 'is_primary not null');

SELECT col_is_pk('landable', 'browsers', 'browser_id', 'browser_id is PK');

SELECT indexes_are('landable', 'browsers', ARRAY['landable_screenshots__device_browser_browser_version', 'browsers_pkey'], 'Has proper indexes');

SELECT * FROM finish();

ROLLBACK;