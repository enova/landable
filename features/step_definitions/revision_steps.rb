Then 'the JSON at "$path" should be a page revision\'s ID' do |path|
  id = at_json path
  id.should_not be_nil
  @revision = Landable::PageRevision.find(id)
end
