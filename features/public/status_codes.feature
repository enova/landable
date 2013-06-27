Feature: Page status codes

  Scenario Outline: HTTP response status
    Given a published page "/foo" with status <code>
    When  I GET "/foo"
    Then  the response status should be <code>

    Examples:
      | code |
      |  200 |
      |  301 |
      |  302 |
      |  404 |

  Scenario Outline: Redirects
    Given page "/foo" redirects to "http://google.com" with status <code>
    When  I GET "/foo"
    Then  the response status should be <code>
    And   I should have been redirected to "http://google.com"

    Examples:
      | code |
      |  301 |
      |  302 |
