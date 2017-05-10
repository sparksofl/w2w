class Genre
  include Mongoid::Document
  field :tmdb_id, type: String
  field :name, type: String

  has_and_belongs_to_many :movies

  validates :tmdb_id, :name, presence: true
  validates :name, uniqueness: true

  def self.batch_create(params)
    params.each do |p|
      Genre.create(p)
    end
  end
end
