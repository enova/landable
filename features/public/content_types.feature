Feature: Content types by extension
  As a content author
  I want Landable to deliver the right content type for my content

  Scenario Outline:
    Given a published page "/foo.<ext>"
    When  I GET "/foo.<ext>"
    Then  the response header Content-Type should be "<content_type>"

    Examples:
      | ext  | content_type     |
      | xml  | application/xml  |
      | json | application/json |
      | txt  | text/plain       |
      | html | text/html        |
      | htm  | text/html        |
      | foo  | text/plain       |
