class Genre
  include Mongoid::Document
  field :tmdb_id, type: String
  field :name, type: String

  belongs_to :movie,   inverse_of: :genres

  def batch_create(params)
    params.each do |p|
      Genre.create(p)
    end
  end
end
