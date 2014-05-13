@api
Feature: Templates API
  Scenario: List all templates
    Given there are 3 templates
    When  I GET "/api/templates"
    Then  the response status should be 200
    And   the response should contain 3 "templates"

  Scenario: Create a new template
    When I POST "/api/templates":
      """
      {
        "template": {
          "name": "A template name!",
          "description": "A beautiful template",
          "body": "<div>body</div>",
          "thumbnail_url": "http://foo/bar.jpg"
        }
      }
      """
    Then the response should be 201 "Created"
    And  the JSON at "template/name" should be "A template name!"
    When I follow the "Location" header
    Then the JSON at "template/name" should be "A template name!"

  Scenario: Update a template
    Given a template
    When  I PATCH "/api/templates/{{@template.id}}":
      """
      { "template": { "name": "New day new name" } }
      """
    Then the response should be 200 "OK"
    And  the JSON at "template/name" should be "New day new name"

  Scenario: Publish a template
    Given a template
    When I POST "/api/templates/{{@template.id}}/publish"
    Then the response should be 201 "Created"
    And  the JSON at "template/published_revision_id" should be a template revision's ID
