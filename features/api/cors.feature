@allow-rescue
Feature: Cross-Origin Support

  Scenario Outline: Only supported from declared origins, within the API namespace
    When I request CORS from "<path>" with:
      | origin   | method   |
      | <origin> | <method> |
    Then the response should be <code>

    Examples:
      | path       | origin               | method | code            |
      | /priority  | http://cors.test     | PUT    | 404 "Not Found" |
      | /api/pages | http://cors.test     | PUT    | 200 "OK"        |
      | /api/pages | http://anything.else | PUT    | 404 "Not Found" |

  Scenario: Response headers to successful CORS OPTIONS requests
    When I request CORS from "/api/pages" with:
      | origin           | method |
      | http://cors.test | PUT    |
    Then the response should be 200 "OK"
    And  the response headers should include:
      | header                       | value                         |
      | Access-Control-Allow-Origin  | http://cors.test              |
      | Access-Control-Allow-Methods | GET, POST, PUT, PATCH, DELETE |

