class Actor
  include Mongoid::Document
  field :name, type: String

  has_and_belongs_to_many :movies
end
