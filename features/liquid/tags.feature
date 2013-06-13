Feature: Liquid Tags
  Background:
    Given the asset URI prefix is "https://landable.dev/_assets/"
    And   a page under test
    And   the page has these assets:
      | basename | name | description           |
      | foo.png  | bar  | Baz!                  |
      | wi.pdf   | doc  | Wisconsin Disclosures |

  Scenario: title_tag
    Given the page's body is "{% title_tag %}"
    Then  the rendered content should be:
      """
      <title>Page Under Test</title>
      """

  Scenario: meta_tags
    Given the page's body is "{% meta_tags %}"
    And the page's meta tags are:
      | name     | content            |
      | robots   | noindex,nofollow   |
      | keywords | momoney,moproblems |
    Then the rendered content should be:
      """
      <meta content="noindex,nofollow" name="robots" />
      <meta content="momoney,moproblems" name="keywords" />
      """

  Scenario: img_tag
    Given the page's body is "{% img_tag bar %}"
    Then the rendered content should be:
      """
      <img alt="Baz!" src="https://landable.dev/_assets/foo.png" />
      """

  Scenario: asset_url and asset_description
    Given the page's body is:
      """
      <a href="{% asset_url doc %}" title="{% asset_description doc %}">Disclosures</a>
      """
    Then the rendered content should be:
      """
      <a href="https://landable.dev/_assets/wi.pdf" title="Wisconsin Disclosures">Disclosures</a>
      """

   Scenario: All of the above, in a theme
     Given the page uses a theme with the body:
       """
       <html>
         <head>{% title_tag %}</head>
         <body>
           {% img_tag bar %}
           {{body}}
         </body>
       </html>
       """
     And the page's body is "The page body here"
     Then the rendered content should be:
       """
       <html>
         <head><title>Page Under Test</title></head>
         <body>
           <img alt="Baz!" src="https://landable.dev/_assets/foo.png" />
           The page body here
         </body>
       </html>
       """
