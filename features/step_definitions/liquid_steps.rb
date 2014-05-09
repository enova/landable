Given 'the asset URI prefix is "$uri"' do |uri|
  # Kinda bogus, but makes explicit tests significantly easier
  Landable::Asset.stub(:url_generator) do
    proc { |asset|
      uri = "#{uri}/" unless uri.ends_with?('/')
      "#{uri}#{asset.data}"
    }
  end
end

Given /^a page under test$/ do
  @page = Landable::Page.new(title: "Page Under Test")
end

Given "the page's body is \"$body\"" do |body|
  @page.body = body
end

Given "the page's body is:" do |body|
  @page.body = body
end

Given "the page's meta tags are:" do |table|
  @page.meta_tags = {}
  table.hashes.each do |tag|
    @page.meta_tags[tag['name']] = tag['content']
  end
end

Given "the page's head tag is \"$tag\"" do |tag|
  @page.head_content = tag
end

Given "the page uses a theme with the body:" do |body|
  @page.theme ||= Landable::Theme.new
  @theme ||= @page.theme
  @page.theme.body = body
end

Given "these assets:" do |table|
  table.hashes.each do |attrs|
    create :asset, attrs
  end
end

Given 'a theme with the body:' do |body|
  @theme = Landable::Theme.new body: body
end

Given 'a theme with the body "$body"' do |body|
  @theme = Landable::Theme.new body: body
end

Given 'the template "$template_slug" with body "$template_body"' do |template_slug, template_body|
  @template = Landable::Template.create! name: template_slug, slug: template_slug, body: template_body, description: template_slug
end

Given 'the template "$template_slug" with the body:' do |template_slug, template_body|
  @template = Landable::Template.create! name: template_slug, slug: template_slug, body: template_body, description: template_slug
end

When  'the template "$published_variable" been published' do |published_variable|
  if published_variable == 'has'
    @template.publish! author: create(:author), notes: 'initial revision', is_minor: true
  end
end

Given 'the template is a filed backed partial' do
  # Parial Defined in spec/dummy/app/views/partials/_foobazz, and configured in spec/dummy/app/config/initializers/landable
  Landable::Template.create_from_partials!
  @responder = Landable::PageRenderResponder
  @responder.stub(:controller) do
    controller = ActionController::Base.new
    controller.request = double('request', variant: nil)

    controller
  end
end

When 'this page is rendered:' do |body|
  @page = Landable::Page.new body: body
  @page.theme = @theme
  @rendered_content = Landable::RenderService.call(@page)
end

Then 'the rendered content should be:' do |body|
  @responder ||= nil
  @rendered_content ||= Landable::RenderService.call(@page, responder: @responder)
  @rendered_content.strip.should == body.strip
end
