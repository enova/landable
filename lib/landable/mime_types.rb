# Re-register application/json, adding our own vendored mime types as aliases

api_mime_types = %W(
  application/vnd.landable.v#{Landable::API_VERSION}+json
  application/vnd.landable+json
  text/x-json
  application/jsonrequest
)

Mime::Type.unregister :json
Mime::Type.register 'application/json', :json, api_mime_types
