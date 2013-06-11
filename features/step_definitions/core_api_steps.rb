# Lame file name, but I don't know what else to call it atm.

expand_mustache = lambda do |context, str|
  if str.respond_to?(:gsub)
    str.gsub(/\{\{(.+?)\}\}/) { context.eval($1) }
  else
    str
  end
end

Before '@api' do
  header 'Accept',       'application/json'
  header 'Content-Type', 'application/json'
end

Before '@no-api-auth' do
  header 'Authorization', nil
end

Given 'my API requests include a valid access token' do
  @current_author ||= create :author
  @current_access_token ||= create :access_token, author: @current_author
  header 'Authorization', encode_basic_auth(@current_author.username, @current_access_token.id)
end

When /^I (HEAD|GET|POST|PUT|PATCH|DELETE|OPTIONS)(?: to)? "(.+?)"$/ do |http_method, path|
  path = path.sub(/^\/api\//, '/landable/')
  request expand_mustache[binding, path], method: http_method
end

When /^I (POST|PUT|PATCH|DELETE|OPTIONS)(?: to)? "(.+?)" with:$/ do |http_method, path, body|
  path = path.sub(/^\/api\//, '/landable/')
  request expand_mustache[binding, path], method: http_method, params: body
end

Then /^the response status should be (\d{3})(?: "[A-Za-z ]+")?$/ do |code|
  last_response.status.should == Integer(code)
end

Then 'the response body should be empty' do
  last_response.body.should be_blank
end
