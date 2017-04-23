json.extract! source_api, :id, :name, :access_url, :website, :default, :created_at, :updated_at
json.url source_api_url(source_api, format: :json)
