Reports
=======

## Traffic

* by `URI`
* by `URI -> page_version`

* Can store metadata [title, description, keywords] versioned?

Features
========
* `desktop / responsive` switching and tracking, cookie to remember


## Paths

*Represents a URI on your site.*

* `has_many pages`

URI - /about-us.html

    CREATE TABLE locations (
        location_id       SERIAL PRIMARY KEY
      , location          TEXT      NOT NULL
      , created_at        TIMESTAMP NOT NULL DEFAULT NOW()
      , http_location_id  INTEGER
          REFERENCES locations
      , http_status       TEXT      NOT NULL DEFAULT 200
    )


Content/template

* Can have multiple versions
* published/unpublished
 

```md
pages
-----
page_id


has_many visits

page_versions
-------------
page_version_id
layout_id
body
published_at
created_at
created_by

authorships
-----------
authorship_id
page_version_id
author_id

authors
-------
author_id
author

layouts
-------
layout_id
layout

cookies
--------
cookies_id
cookie_uuid
user/account id

COOKIE 1 - desktop
* visit 1 -> browse around      [source: ppc] -> user_id 45, inferred_user_id [45, 72]
* visit 2 -> start registering  [source: aff] -> registration_id user_id 45

= visit 3 -> finish registering [source: direct] -> registration_id -> user_id 45 -> backfill visit 1 and 2 with account_id 45

= visit 4 -> login -> user_id 45

= visit 5 -> login -> user_id 72 -> wipe the cookie's user identifier if different

COOKIE 2 - iphone
- visit 1 -> browse [source: direct] -> user_id 45, inferred_user_id [45]
= visit 2 -> login -> user_id 45

COOKIE 3 - ipad
? visit 1 -> browse [source: direct]


identifications
---------------
identification_id
cookie_id
user_id


SELECT user_id FROM identfied_visits;

visit
-----
visit_id
cookie_id
user_id
user_agent_id
platform_id
browser_id
device_id
ip_address_id
created_at
updated_at

ip_addresses
------------
ip_address_id
ip_address

mediums
-------
medium_id
medium

sources
-------
source_id
source

campaigns
---------
campaign_id
campaign

page_views
----------
page_view_id
visit_id
path_id
page_version_id
http_status NOT NULL
created_at
? response_time

user_agents
-----------
user_agent_id
user_agent

platforms
---------
platform_id
platform

browsers
--------
browser_id
browser

devices
-------
device_id
device
width  INTEGER
height INTEGER
```
