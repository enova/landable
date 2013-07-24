@api
Feature: Themes API
  Scenario: List all themes
    Given 3 themes
    When I GET "/api/themes"
    Then the response status should be 200
    And  the response should contain 3 "themes"

  Scenario: Create a new theme
    When I POST "/api/themes":
      """
      {
        "theme": {
          "name": "A theme name!",
          "description": "A beautiful theme",
          "body": "{{ body }}",
          "thumbnail_url": "http://foo/bar.jpg"
        }
      }
      """
    Then the response should be 201 "Created"
    And  the JSON at "theme/name" should be "A theme name!"
    When I follow the "Location" header
    Then the JSON at "theme/name" should be "A theme name!"

  Scenario: Update a theme
    Given a theme
    When  I PATCH "/api/themes/{{@theme.id}}":
      """
      { "theme": { "name": "New day new name" } }
      """
    Then the response should be 200 "OK"
    And  the JSON at "theme/name" should be "New day new name"
