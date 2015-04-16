# Re-register application/json, adding our own vendored mime types as aliases

# TODO: Be more generous about accepting version constraints. Currently,
# requesting v1.5 when we're running v1.5.2 will return a 406.

api_mime_types = %W(
  application/vnd.landable.v#{Landable::VERSION::MAJOR}+json
  application/vnd.landable.v#{Landable::VERSION::STRING}+json
  application/vnd.landable+json
  text/x-json
  application/jsonrequest
)

Mime::Type.unregister :json
Mime::Type.register 'application/json', :json, api_mime_types
