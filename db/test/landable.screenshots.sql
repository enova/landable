BEGIN;
SELECT PLAN(6);

SELECT col_is_fk('landable', 'screenshots', 'browser_id', 'screenshots have browser_id fk');

SELECT col_not_null('landable', 'screenshots', 'screenshotable_id', 'screenshotable_id not null');
SELECT col_not_null('landable', 'screenshots', 'screenshotable_type', 'screenshotable_type not null');

SELECT col_is_pk('landable', 'screenshots', 'screenshot_id', 'screenshot_id is PK');

SELECT indexes_are('landable', 'screenshots', ARRAY['landable_screenshots__screenshotable_id_screenshotable_type_state', 'landable_screenshots__state', 'landable_screenshots__u_browserstack_id', 'screenshots_pkey'], 'Has proper indexes');
SELECT index_is_unique('landable', 'screenshots', 'landable_screenshots__u_browserstack_id', 'browserstack_id index is unique');

SELECT * FROM finish();

ROLLBACK;