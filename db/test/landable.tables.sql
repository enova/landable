BEGIN;

  SELECT PLAN(1);

  SELECT tables_are('landable'
                      , ARRAY[ 
                          'pages'
                          , 'page_revisions'
                          , 'assets'
                          , 'head_tags'
                          , 'status_code_categories'
                          , 'status_codes'
                          , 'themes'
                          , 'templates'
                          , 'authors'
                          , 'access_tokens'
                          , 'categories'
                          , 'browsers'
                          , 'screenshots'
                          , 'page_assets'
                          , 'page_revision_assets'
                          , 'theme_assets'
                        ]
                      , $$ Only expected tables exist $$);

  SELECT FINISH();

ROLLBACK;
