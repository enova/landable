BEGIN;

SELECT PLAN(6);

SELECT col_is_pk('landable', 'templates', 'template_id', 'Template_id is pk');
SELECT col_not_null('landable', 'templates', 'name', 'name is NOT NULL');
SELECT col_not_null('landable', 'templates', 'body', 'body is NOT NULL');
SELECT col_not_null('landable', 'templates', 'description', 'description is NOT NULL');

SELECT has_index('landable', 'templates', 'landable_templates__u_name', 'Index on name');
SELECT index_is_unique('landable', 'templates', 'landable_templates__u_name', 'name index is unique');

SELECT * FROM finish();

ROLLBACK;