# Landable API Design

## Themes
1. GET /themes => { themes: [{ name: "", body: "", screenshots: ["http://..."]}] }

## Categories
1. GET /categories => { categories: [{ name: "SEO", count: 120 }] }

## Pages
### Listings
1. GET /pages?directory=/ => { directories: [{ path: "/seo", count: 100 }], pages: [{...}] }
2. GET /pages?directory=/seo
3. GET /pages?category=SEO (or category=UUID?)

### CRUD
1. GET /pages/UUIDHERE => { page: { id: "UUID", body: "", theme: { name: "", body: "" }, category: "", path: "", status_code: 200 }}
2. POST /pages (PUT /pages/UUIDHERE?)
3. PATCH /pages/UUIDHERE
4. GET /pages/UUIDHERE/preview => text/html

## CORS
We want [publicist](https://git.cashnetusa.com/trogdor/publicist) to be 99% client side, with JS taking care of the communication with the various backing APIs. Because the JS will be served from `publicist.whatever.com`, but will need to communicate with `our-public-site.com/_landable_api`, we need to support [Cross-Origin Resource Sharing](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing).

For example, my local landable application is configured to permit requests from `publicist.dev`:

~~~
# This would be sent by the browser when making a CORS request for http://landable.dev/landable/pages
» curl --head -XOPTIONS -H 'Access-Control-Request-Method: GET'  -H 'Origin: http://publicist.dev' http://landable.dev/landable/pages 
HTTP/1.1 200 OK
Content-Type: text/plain
Access-Control-Allow-Origin: http://publicist.dev
Access-Control-Allow-Methods: GET, POST, PATCH, DELETE
Access-Control-Expose-Headers: 
Access-Control-Max-Age: 900
Cache-Control: no-cache
X-Request-Id: abc7f559-c16a-44f1-b6d5-c8c2146cd920
X-Runtime: 0.003242
Connection: close

# 404 Not Found, because we only enable CORS support for the landable API
» curl --head -XOPTIONS -H 'Access-Control-Request-Method: GET'  -H 'Origin: http://publicist.dev' http://landable.dev
HTTP/1.1 404 Not Found
Content-Type: text/html; charset=utf-8
Content-Length: 17906
X-Request-Id: 48e1554d-9ae5-4b17-aaac-38abbac29e7b
X-Runtime: 0.041836
Connection: keep-alive
~~~
