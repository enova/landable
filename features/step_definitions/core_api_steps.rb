# Lame file name, but I don't know what else to call it atm.

expand_mustache = lambda do |context, str|
  if str.respond_to?(:gsub)
    str.gsub(/\{\{([^ ].+?)\}\}/) { context.eval(Regexp.last_match(1)) }
  else
    str
  end
end

module Landable
  module FeatureHelper
    def basic_authorize!(author = current_author, token = current_access_token)
      basic_authorize author.username, token.id
    end

    def current_author
      @current_author ||= create :author_without_access_tokens
    end

    def current_access_token
      @current_access_token ||= create :access_token, author: @current_author
    end

    def last_json(body = last_response.body)
      JSON.parse body
    end

    def latest(model)
      model = model.to_s.classify
      klass = "Landable::#{model}".constantize
      klass.order('created_at DESC').first!
    end
  end
end

World(Landable::FeatureHelper)

Before '@api' do
  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'
end

Before '@api', '~@no-api-auth' do
  basic_authorize!
end

Given 'I accept HTML' do
  header 'Accept', 'text/html'
end

Given 'I accept JSON' do
  header 'Accept', 'application/json'
end

Given 'my API requests include a valid access token' do
  basic_authorize!
end

Given 'I repeat the request with a valid access token' do
  basic_authorize!
  request last_request.url, last_request.env
end

Given 'my access token will expire in 2 minutes' do
  current_access_token.update_attributes!(expires_at: 2.minutes.from_now)
end

Given 'my access token expired 2 minutes ago' do
  current_access_token.update_attributes!(expires_at: 2.minutes.ago)
end

When(/^I (HEAD|GET|POST|PUT|PATCH|DELETE|OPTIONS)(?: to)? "(.+?)"$/) do |http_method, path|
  request expand_mustache[binding, path], method: http_method
end

When(/^I (POST|PUT|PATCH|DELETE|OPTIONS)(?: to)? "(.+?)"(?: with)?:$/) do |http_method, path, body|
  request expand_mustache[binding, path], method: http_method, params: body
end

When 'I request CORS from "$path" with:' do |path, table|
  options = table.hashes.first

  header 'Origin', options['origin']
  header 'Access-Control-Request-Method', options['method']
  request path, method: 'OPTIONS'
end

When 'I follow the "Location" header' do
  get last_response.headers['Location']
end

Then 'my access token should not expire for at least 2 hours' do
  token = current_access_token.reload
  token.expires_at.should be >= 2.hours.from_now
end

Then(/^the response(?: status)? should(?: (not))? be (\d{3})(?: "[A-Za-z ]+")?$/) do |negate, code|
  code = Integer(code)
  if negate == 'not'
    last_response.status.should_not eq(code)
  else
    last_response.status.should eq(code)
  end
end

Then(/^the response should contain (?:a|an) "([^"]+)"$/) do |model|
  last_json.should have_key(model)
  last_json[model].should have_key('id')
end

Then(/^the response should contain (\d+) "([^"]+)"$/) do |count, kind|
  last_json[kind].length.should eq Integer(count)
end

Then 'the response body should be empty' do
  last_response.body.should be_blank
end

Then 'the response body should be "$body"' do |body|
  last_response.body.should eq body
end

Then 'I should have been redirected to "$url"' do |url|
  last_response.headers['Location'].should eq url
end

Then 'the response headers should include:' do |table|
  expected = table.hashes.reduce({}) do |acc, row|
    acc.merge row['header'] => row['value']
  end
  last_response.headers.should include(expected)
end

Then 'the JSON at "$path" should be "$value"' do |json_path, value|
  at_json(json_path).should eq value
end

Then 'the response header "$header" should be "$content_type"' do |header, content_type|
  last_response.headers[header].should include(content_type)
end
