# Landable API Design

## Authentication
TBD.

## Themes
### GET /themes
~~~~json
{ "themes": [
    { "name": "CNU TV", "screenshot_urls": ["http://..."] }
  ]
}
~~~~

## Pages
### GET /pages/UUID
1. Returns 200 + JSON body (see below).
2. Returns 404 if UUID did not exist.

~~~~json
{ "page": {
    "path": "/some/path",
    "status_code": 200,
    "redirect_url": null,
    "theme": { "name": "CNU TV", "screenshot_urls": [] },
    "title": "Page Title",
    "body": "<div>HTML content</div>"
  }
}
~~~~

### GET /pages/UUID/preview
1. Returns 200 + `text/html` for the rendered page contents.
2. Returns 400 Bad Request if asking to preview a non-200 page.
3. Returns 404 if UUID did not exist.

### POST /pages
1. Returns 201 on success.
2. Returns 422 on error.

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
