class SourceApi
  include Mongoid::Document
  field :name, type: String
  field :access_url, type: String
  field :website, type: String
  field :default, type: Mongoid::Boolean
end
