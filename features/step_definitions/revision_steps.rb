Then 'the JSON at "$path" should be a page revision\'s ID' do |path|
  id = at_json path
  id.should_not be_nil
  @revision = Landable::PageRevision.find(id)
end

Then 'the JSON at "$path" should be a template revision\'s ID' do |path|
  id = at_json path
  id.should_not be_nil
  @revision = Landable::TemplateRevision.find(id)
end
