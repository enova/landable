# For any spec tagged with `api: true`:
#
# The HTTP request `Accept` header is set to `application/json`.
#
# An author and access token are created and used to generate
# an HTTP request `Authorization` header. To skip this behavior,
# tag the spec with `auth: false`.
shared_context 'JSON API', json: true do
  before do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end

  def last_json
    @last_json ||= JSON.parse response.body
  end
end

# Generates tests that confirm HTTP Basic Authentication is
# being used to authenticated requests to a controller action.
#
# Example:
#     describe Some::Api::Controller, '#create', api: true do
#       include_examples 'API authentication', :make_request
#
#       def make_request
#         post :create, some: 'param', values: 'here'
#       end
#     end
shared_examples 'API authentication' do |request_method|
  raise ArgumentError.new("Method name required as argument") if request_method.nil?

  before do
    use_access_token unless example.metadata[:auth] == false
  end

  def current_author
    @current_author ||= create :author
  end

  def current_access_token
    @current_access_token ||= create :access_token, author: current_author
  end

  def use_access_token
    request.env['HTTP_AUTHORIZATION'] = encode_basic_auth(current_author.username, current_access_token.id)
  end

  def do_not_use_access_token
    request.env.delete 'HTTP_AUTHORIZATION'
  end

  it 'returns 401 if unauthorized', auth: false do
    send(request_method)
    response.status.should == 401
  end
end
