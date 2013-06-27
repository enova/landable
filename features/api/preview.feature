@api
Feature: Preview Page

  Scenario: Preview a page
    Given I accept HTML
    When I POST "/api/pages/preview":
    """
    {
      "page": {
        "path": "/page/path",
        "body": "This is just a preview!",
        "status_code": "200"
      }
    }
    """
    Then the response should be 200 "OK"
