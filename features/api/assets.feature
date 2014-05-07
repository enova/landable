@api
Feature: Asset management API

  @no-api-auth @allow-rescue
  Scenario Outline: Authentication required
    When I <verb> "<path>"
    Then the response should be 401 "Not Authorized"
    When I repeat the request with a valid access token
    Then the response should not be 401 "Not Authorized"

    Examples:
      | verb   | path                   |
      | GET    | /api/assets            |
      | GET    | /api/assets/1          |
      | POST   | /api/assets            |

  Scenario: Getting all assets
    Given 3 assets
    When  I GET "/api/assets"
    Then  the response should contain 3 "assets"

  Scenario: Getting multiple assets by ID
    Given 3 assets
    When  I GET "/api/assets?ids[]={{@assets[0].id}}&ids[]={{@assets[1].id}}"
    Then  the response should contain 2 "assets"

  Scenario: Searching by asset name
    Given 2 assets named "panda" and "disclaimer"
    When  I GET "/api/assets?search[name]=p"
    Then  the response should contain 1 "assets"
    And   the JSON at "assets/0/name" should be "panda"

  Scenario: Uploading a new asset
    When I POST an asset to "/api/assets"
    Then the response should be 201 "Created"
    And  the response should contain an "asset"
    When I follow the "Location" header
    Then the response should contain the same "asset"

  Scenario: Uploading a pre-existing asset, based on SHA
    Given an asset
    When  I POST that asset to "/api/assets" again
    Then  the response should be 301 "Moved Permanently"
    And   the response body should be empty
    When  I follow the "Location" header
    Then  the response should contain the original "asset"
