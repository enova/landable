BEGIN;

  SELECT PLAN(1);

  SELECT tables_are('landable'
                      , ARRAY[ 
                          'pages'
                          , 'page_revisions'
                          , 'assets'
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
