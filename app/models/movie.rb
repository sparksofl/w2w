class Movie
  include Mongoid::Document
  field :title, type: String
  field :tmdb_id, type: Integer
  field :imdb_id, type: String
  field :overview, type: String
  field :keywords, type: String
  field :tagline, type: String
  field :poster_path, type: String

  def self.batch_create(params)
    attrs = (attribute_names - ['_id', 'tmdb_id'])
    params.each do |p|
      movie = Movie.new
      attrs.each { |a| movie[a] = p[a] }
      movie[:tmdb_id] = p['id']
      movie.poster_path = "http://image.tmdb.org/t/p/w185/#{movie.poster_path}"
      movie.save
    end
  end
end
