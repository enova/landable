BEGIN;

SELECT PLAN(6);

SELECT col_is_pk('dummy_landable', 'templates', 'template_id', 'Template_id is pk');
SELECT col_not_null('dummy_landable', 'templates', 'name', 'name is NOT NULL');
SELECT col_not_null('dummy_landable', 'templates', 'body', 'body is NOT NULL');
SELECT col_not_null('dummy_landable', 'templates', 'description', 'description is NOT NULL');

SELECT has_index('dummy_landable', 'templates', 'dummy_landable_templates__u_name', 'Index on name');
SELECT index_is_unique('dummy_landable', 'templates', 'dummy_landable_templates__u_name', 'name index is unique');

SELECT * FROM finish();

ROLLBACK;