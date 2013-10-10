BEGIN;

SELECT PLAN(6);

--Verify PK and FK columns
SELECT col_is_fk('landable', 'pages', 'published_revision_id', 'pages have published_revision_id fk');
SELECT col_is_fk('landable', 'pages', 'theme_id', 'pages have theme_id fk');
SELECT col_is_fk('landable', 'pages', 'category_id', 'pages have category_id fk');
SELECT col_is_pk('landable', 'pages', 'page_id', 'page_id is PK');

--Verify unique index on path
SELECT index_is_unique('landable', 'pages', 'landable_pages__u_path', 'Path index is unique');

--Verify valid paths
SELECT throws_matching($$INSERT INTO landable.pages (is_publishable, path, status_code) VALUES ('true', 'good/page4', 200)$$, 'violates check', 'valid path');

SELECT * FROM finish()

ROLLBACK;
