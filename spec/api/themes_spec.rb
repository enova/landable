require 'spec_helper'

describe 'GET /themes', json: true do
  include_examples 'API authentication', :make_request

  def make_request
    get '/themes'
  end

  it 'returns all themes' do
    theme = Landable.themes.first
    Landable.stub!(themes: [theme])

    make_request
    response.status.should == 200

    json['themes'].length.should == 1
    json['themes'][0].should include({
      'name' => theme.name, 'description' => theme.description, 'layout' => theme.layout, 'screenshot_urls' => theme.screenshot_urls
    })
  end

  # getting '/themes', accept: 'html', format: 'json', params: { ... }, headers: { ... } do
  #   its(:status)       { should == 200 }
  #   its(:content_type) { should be_json }
  #
  #   body do # body :json, but inherited from :format
  #     its(:keys) { should == ['themes'] }
  #   end
  #
  #   body at: 'json/path/0' do
  #     it { should match_record(Page.find(0)) }
  #     its(['name']) { should == 'greg' }
  #   end
  #
  #   with params: { foo: '1' }, headers: { foo: '2' } do
  #   end
  # end
end
