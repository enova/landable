BEGIN;

SELECT PLAN(6);

--Verify PK and FK columns
SELECT col_is_fk('dummy_landable', 'pages', 'published_revision_id', 'pages have published_revision_id fk');
SELECT col_is_fk('dummy_landable', 'pages', 'theme_id', 'pages have theme_id fk');
SELECT col_is_fk('dummy_landable', 'pages', 'category_id', 'pages have category_id fk');
SELECT col_is_pk('dummy_landable', 'pages', 'page_id', 'page_id is PK');

--Verify unique index on path
SELECT index_is_unique('dummy_landable', 'pages', 'dummy_landable_pages__u_path', 'Path index is unique');

--Verify valid paths
SELECT throws_matching($$INSERT INTO dummy_landable.pages (is_publishable, path, status_code) VALUES ('true', 'good/page4', 200)$$, 'violates check', 'valid path');

SELECT * FROM finish()

ROLLBACK;
