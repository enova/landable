# Lame file name, but I don't know what else to call it atm.

expand_mustache = lambda do |context, str|
  if str.respond_to?(:gsub)
    str.gsub(/\{\{([^ ].+?)\}\}/) { context.eval($1) }
  else
    str
  end
end

module Landable::FeatureHelper
  def basic_authorize!(author = current_author, token = current_access_token)
    basic_authorize author.username, token.id
  end

  def current_author
    @current_author ||= create :author
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

World(Landable::FeatureHelper)

Before '@api' do
  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'
end

Before '@api', '~@no-api-auth' do
  basic_authorize!
end

Given 'my API requests include a valid access token' do
  basic_authorize!
end

Given 'my access token will expire in 2 minutes' do
  current_access_token.update_attributes!(expires_at: 2.minutes.from_now)
end

Given 'my access token expired 2 minutes ago' do
  current_access_token.update_attributes!(expires_at: 2.minutes.ago)
end

When /^I (HEAD|GET|POST|PUT|PATCH|DELETE|OPTIONS)(?: to)? "(.+?)"$/ do |http_method, path|
  request expand_mustache[binding, path], method: http_method
end

When /^I (POST|PUT|PATCH|DELETE|OPTIONS)(?: to)? "(.+?)"(?: with)?:$/ do |http_method, path, body|
  request expand_mustache[binding, path], method: http_method, params: body
end

Then 'my access token should not expire for at least 2 hours' do
  token = current_access_token.reload
  token.expires_at.should be >= 2.hours.from_now
end

Then /^the response status should be (\d{3})(?: "[A-Za-z ]+")?$/ do |code|
  last_response.status.should == Integer(code)
end

Then /^the response should contain (\d+) ([\w\s]+)$/ do |count, kind|
  last_json['themes'].length.should == 3
end

Then 'the response body should be empty' do
  last_response.body.should be_blank
end

Then 'the response body should be "$body"' do |body|
  last_response.body.should == body
end

Then 'I should have been redirected to "$url"' do |url|
  last_response.headers['Location'].should == url
end
