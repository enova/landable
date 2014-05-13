Given /^(\d+) ([\w\s]+)$/ do |count, kind|
  klass = kind.gsub(/\s+/, '_').singularize.classify.gsub(/^/, 'Landable::').constantize
  klass.destroy_all

  result = Integer(count).times.map do
    create kind.gsub(/\s+/, '_').singularize.to_sym
  end

  instance_variable_set :"@#{kind}", result
end

Given 'there are 3 templates' do
  number_needed = 3 - Landable::Template.count
  FactoryGirl.create_list(:template, number_needed)
end

Given /^an author "([^"]+)"$/ do |username|
  create :author, username: username
end

Given '"$username" has an unexpired access token' do |username|
  create :access_token, author: Landable::Author.where(username: username).first!
end

Given 'I also have an older, expired access token' do
  @expired_access_token = create :access_token, author: @current_author, expires_at: 2.minutes.ago
end

Given "there is another author's access token in the database" do
  @foreign_access_token = create :access_token, author: create(:author)
end

Given /^an? (page|theme|asset|template)$/ do |model|
  instance_variable_set :"@#{model}", create(model.to_sym)
end

Given /^a (page|theme) with an asset attached$/ do |model|
  record = create model.to_sym
  @asset = create :asset
  record.assets.push @asset
  instance_variable_set :"@#{model}", record
end

Given /^a page "([^"]+)"$/ do |path|
  create :page, path: path, body: "<HTML>BODY</HTML>"
end

Given /^a page "([^"]+)" with title "(.+)"$/ do |path, title|
  create :page, path: path, title: title, body: "<HTML>BODY</HTML>"
end

Given /^a "(\w+)" page with title "(.+)" and category "(.+)"$/ do |published, title, category|
  category_obj = Landable::Category.where('lower(name) = ?', category.downcase).first
  @page = create :page, title: title, category: category_obj
  @page.publish! author: create(:author) if published == 'published'
end

Given 'page "$path" redirects to "$url" with status $code' do |path, url, code|
  page = create :page, :redirect, path: path, redirect_url: url, status_code: code, body: "BODY"
  page.publish! author: create(:author)
end

Given 'a published page "$path"' do |path|
  @page = create :page, path: path
  @page.publish! author: create(:author)
end

Given 'a published page "$path" with status $code' do |path, code|
  code = Integer(code)
  page = case code
         when 301, 302 then create :page, :redirect, path: path, status_code: code, body: "BODY"
         when 410 then create :page, :gone, path: path, body: "BODY"
         else create :page, path: path, body: "BODY"
         end
  page.publish! author: create(:author)
end

Given 'a published page "$path" titled "$title" with theme "$name"' do |path, title, theme|
  page = create :page, path: path, title: title, theme: create(:theme, name: theme)
  page.publish! author: create(:author)
end

Given 'the body of theme "$name" is "$body"' do |name, body|
  theme = Landable::Theme.where(name: name).first!
  theme.update_attributes! body: body
end

Given 'the $tag meta tag of "$path" is "$value"' do |tag, path, value|
  page = Landable::Page.by_path!(path)
  page.meta_tags ||= {}
  page.meta_tags.merge! tag => value
  page.save!
end

Given 'the body of page "$path" is:' do |path, body|
  Landable::Page.by_path!(path).update_attributes(body: body)
end

When 'I publish the page "$path"' do |path|
  Landable::Page.by_path!(path).publish! author: create(:author)
end

When(/^I change the page to a (\d+)$/) do |code|
  @page.status_code = code
  @page.save!
end

Then /^there should be (\d+) ([\w\s]+) in the database$/ do |count, kind|
  name  = kind.gsub(/\s+/, '_').classify
  klass = "Landable::#{name}".constantize
  klass.count.should eql(Integer(count))
end

Then 'an author "$username" should exist' do |username|
  Landable::Author.where(username: username).first!
end

Given 'an author "$username" does not exist' do |username|
  Landable::Author.where(username: username).present?.should be_false
end

Then /^the author "(.+?)" should have (\d+) access tokens?$/ do |username, n|
  author = Landable::Author.where(username: username).first!
  author.access_tokens.count.should == Integer(n)
end

Then 'the response body should include the body of page "$path"' do |path|
  last_response.body.should include(Landable::Page.by_path!(path).body)
end
