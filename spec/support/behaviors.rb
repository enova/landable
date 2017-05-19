shared_context 'API endpoint', type: :request do
  let(:default_parameters) do
    {}
  end

  let(:default_headers) do
    {}
  end

  [:get, :post, :put, :patch, :delete, :head].each do |method|
    define_method(method) do |path, parameters = {}, headers = {}|
      path = "/landable/#{path}".squeeze('/')
      super path, parameters.reverse_merge(default_parameters), headers.reverse_merge(default_headers)
    end
  end

  def current_author
    @current_author ||= create :author
  end

  def current_access_token
    @current_access_token ||= create :access_token, author: current_author
  end
end

shared_context 'JSON API endpoint', type: :request do
  before do
    default_parameters[:format] ||= 'json'
    default_headers['HTTP_ACCEPT'] ||= 'application/json'
  end

  def json(reload = false)
    return @_last_json if @_last_json && !reload
    @_last_json ||= JSON.parse(response.body)
  end
end

shared_examples 'API authentication' do |request_method|
  include Landable::Spec::HttpHelpers

  before do
    default_headers['HTTP_AUTHORIZATION'] ||= encode_basic_auth(current_author.username, current_access_token.id)
  end

  it 'returns 401 if unauthorized' do
    default_headers.delete 'HTTP_AUTHORIZATION'
    send(request_method)
    expect(response.status).to eq 401
  end
end

# For any controller spec tagged with `api: true`:
#
# The HTTP request `Accept` header is set to `application/json`.
#
# An author and access token are created and used to generate
# an HTTP request `Authorization` header. To skip this behavior,
# tag the spec with `auth: false`.
shared_context 'JSON API Controller', type: :controller do
  before do
    request.env['HTTP_ACCEPT'] = 'application/json' if RSpec.current_example.metadata[:json] == true
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
shared_examples 'Authenticated API controller' do |request_method|
  fail(ArgumentError, 'Method name required as argument') if request_method.nil?

  before do
    use_access_token unless RSpec.current_example.metadata[:auth] == false
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
    expect(response.status).to eq 401
  end
end
