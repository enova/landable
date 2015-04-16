def make_request(id = page.id)
  get :show, id: id
end

Given 'a published page "$path" with a theme containing "$body"' do |path, body|
  @theme = create :theme, body: body
  @page = create :page, path: path, theme: @theme
  @page.publish! author: create(:author)
end

When 'I choose another theme containing "$body"' do |body|
  @new_theme = create :theme, body: body
  @page.theme = @new_theme
end

When 'I change the theme to contain "$body"' do |body|
  @page.theme.body = body
  @page.save
end

And "I GET '/pubbed'" do
  make_request
end

Then 'I should see "$body"' do |_body|
  @page.reload
  last_response.body.should include(@page.theme.body)
end

When 'I publish the page with another theme' do
  @page.theme = @new_theme
  @page.save
  @page.publish! author: create(:author)
end

When(/^I publish the page$/) do
  @page.publish! author: create(:author)
end

When 'I revert to the previous revision' do
  revision = @page.revisions.order('created_at asc').first
  @page.revert_to! revision
end
