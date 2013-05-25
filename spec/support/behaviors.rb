shared_context 'JSON API', api: true do
  before do
    request.env['HTTP_ACCEPT'] = 'application/json'
  end
end
