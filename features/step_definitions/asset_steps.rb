# a bit specific eh ...
Given '2 assets named "panda" and "disclaimer"' do
  @assets = [create(:asset, name: 'panda', fixture: 'panda.png'),
             create(:asset, name: 'disclaimer', fixture: 'small.pdf')]
end

When 'I POST an asset to "$path"' do |path|
  post path, asset: attributes_for(:asset, fixture: 'panda.png')
  last_request.should be_form_data
end

When 'I POST that asset to "$path" again' do |path|
  post path, asset: attributes_for(:asset, fixture: 'panda.png')
  last_request.should be_form_data
end

When 'I POST an asset to "$path" with both $assoc IDs' do |path, assoc|
  ary = instance_variable_get("@#{assoc}s")
  key = :"#{assoc}_ids"

  post path, asset: attributes_for(:asset).merge(key => ary.map(&:id))
end

Then 'the response should contain an "asset"' do
  last_json.should have_key('asset')
  last_json['asset']['mime_type'].should eq 'image/png'
end

Then 'the response should contain the $version "asset"' do |_|
  # version is intentionally ignored; it just reads better in the steps.

  @asset ||= Landable::Asset.order('created_at DESC').first
  at_json('asset/id').should eq @asset.id
end

Then(/^the asset ID should( not)? be in the array at "([^"]+)"$/) do |negative, json_path|
  array = at_json json_path
  if negative
    array.should_not include(@asset.id)
  else
    array.should include(@asset.id)
  end
end

Then 'both $assoc IDs should be in the array at "$json_path"' do |assoc, json_path|
  ids = instance_variable_get("@#{assoc}s").map(&:id)
  at_json(json_path).should include(*ids)
end

Then 'the rendered body should be the correct assets' do
  <<-eos
    <link href="/assets/application-//./.css" media="screen" rel="stylesheet" />
    <script src="/assets/application-/./.js"></script>
    <img alt="Foo" src="/assets/foo-/./.jpg" />
    <img alt="Foo" src="/assets/foo-/./.jpg" />
    <img alt="Baz!" src="https://landable.dev/_assets//uploads/panda.png" />
  eos
end
