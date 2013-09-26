def make_request(id = page.id)
  get :show, id: id
end

When /^I choose another theme for the page$/ do
  @new_theme = create :theme
  @page.theme = @new_theme
end

When "I change the theme's body" do
  @page.theme.body = 'new body'
  @page.save
end

When /^I publish the page$/ do
  @page.theme = @new_theme
  @page.publish! author: create(:author)
end

And  "I GET '/pubbed'" do
  make_request
end

Then /^the original theme should still be shown$/ do
  @page.reload
  @page.theme.should == @theme
end

Then /^the new theme body should be shown$/ do
  @page.theme.body.should == 'new body'
end

Then /^the new theme should now be shown$/ do
  @page.theme.should == @new_theme
end

When 'I revert to the previous revision' do
  revision = @page.revisions.first
  @page.revert_to! revision
end
