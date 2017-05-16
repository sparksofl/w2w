class Keyword
  include Mongoid::Document
  field :name, type: String

  has_and_belongs_to_many :movies

  validates :name, presence: true, uniqueness: true
end
