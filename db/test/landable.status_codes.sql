BEGIN;

SELECT PLAN(4);

--Verify PK and FK columns
SELECT col_is_fk('landable', 'status_codes', 'status_code_category_id', 'Status codes have FK to status_code_category_id');
SELECT col_is_pk('landable', 'status_codes', 'status_code_id', 'status_code_id is PK');

--Verify unique index on code
SELECT index_is_unique('landable', 'status_codes', 'landable_status_codes__u_code', 'Code index is unique');

--Verify seed data loaded
SELECT results_eq($$SELECT COUNT(*)::INT FROM landable.status_codes$$, $$SELECT 4::INT$$, 'Should have 4 seed records');

SELECT * FROM finish()

ROLLBACK;
