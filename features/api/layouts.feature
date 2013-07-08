@api
Feature: Layouts API
  Scenario: List all layouts
    Given 3 layouts
    When I GET "/api/layouts"
    Then the response status should be 200
    And  the response should contain 3 "layouts"
