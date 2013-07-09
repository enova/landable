@api
Feature: Layouts API
  Scenario: List all layouts
    Given 3 layouts
    When I GET "/api/layouts"
    Then the response status should be 200
    And  the response should contain 3 "layouts"

  Scenario: Create a new layout
    When I POST "/api/layouts":
      """
      {
        "layout": {
          "name": "A layout name!",
          "description": "A beautiful layout",
          "body": "<div>body</div>",
          "screenshot_url": "http://foo/bar.jpg"
        }
      }
      """
    Then the response should be 201 "Created"
    And  the JSON at "layout/name" should be "A layout name!"
    When I follow the "Location" header
    Then the JSON at "layout/name" should be "A layout name!"

  Scenario: Update a layout
    Given a layout
    When  I PATCH "/api/layouts/{{@layout.id}}":
      """
      { "layout": { "name": "New day new name" } }
      """
    Then the response should be 200 "OK"
    And  the JSON at "layout/name" should be "New day new name"
