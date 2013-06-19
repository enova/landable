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
