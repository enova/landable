@api
Feature: Pages API

  Scenario: Loading multiple pages
    Given two existing pages
    When  I GET "/api/pages?ids[]={{@pages[0].id}}&ids[]={{@pages[1].id}}"
    Then  the response should be 200 "OK"
    And   the response should contain 2 "pages"

  Scenario: Loading a single page
    Given a page
    When  I GET "/api/pages/{{@page.id}}"
    Then  the response should be 200 "OK"
    And   the response should contain a "page"

  Scenario: Create a new page
    When I POST to "/api/pages" with:
    """
    { "path": "/page" }
    """
    Then the response should be 201 "Created"
    And the JSON at "page/path" should be "/page"

  Scenario: Update a page
    Given a page
    When I PATCH "/api/pages/{{@page.id}}":
    """
    { "page": { "title": "Updated page" } }
    """
    Then the response should be 200 "OK"
    And the JSON at "page/title" should be "Updated page"

  Scenario: Publish a page
    Given a page
    When I POST "/api/pages/{{@page.id}}/publish"
    Then the response should be 201 "Created"
