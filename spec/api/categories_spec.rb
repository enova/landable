require 'spec_helper'

describe 'GET /categories', json: true do
  include_examples 'API authentication', :make_request

  def make_request
    get '/categories'
  end

  it 'returns all categories' do
    category = create :category

    make_request
    response.status.should == 200

    json['categories'].length.should == 1
    json['categories'][0].should include({
      'name' => category.name, 'description' => category.description
    })
  end
end
