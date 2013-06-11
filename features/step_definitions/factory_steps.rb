Given 'there are no authors in the database' do
  Landable::Author.delete_all
end

Given 'an author "$username"' do |username|
  create :author, username: username
end

Given '"$username" has an unexpired access token' do |username|
  create :access_token, author: Landable::Author.where(username: username).first!
end

Given "there is another author's access token in the database" do
  @foreign_access_token = create :access_token, author: create(:author)
end

Then /^there should be (\d+) ([\w\s]+) in the database$/ do |count, kind|
  name  = kind.gsub(/\s+/, '_').classify
  klass = "Landable::#{name}".constantize
  klass.count.should eql(Integer(count))
end

Then 'an author "$username" should exist' do |username|
  Landable::Author.where(username: username).first!
end

Then /^the author "(.+?)" should have (\d+) access tokens?$/ do |username, n|
  author = Landable::Author.where(username: username).first!
  author.access_tokens.count.should == Integer(n)
end
