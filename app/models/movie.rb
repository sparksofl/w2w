class Movie
  include Mongoid::Document
  field :title, type: String
  field :tmdb_id, type: Integer
  field :imdb_id, type: String
  field :overview, type: String
  field :keywords, type: String
  field :tagline, type: String
  field :poster_path, type: String
  field :similar_ids, type: String
  field :desc, type: String
  field :vote_average, type: Integer
  field :release_date, type: String

  has_and_belongs_to_many :genres

  validates :title, :overview, presence: true
  validates :title, uniqueness: true

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

  def self.search(str)
    if str
      str = str.downcase.gsub(/'/, "'''")
      where(title: /.*#{str}.*/i)
    else
      all
    end
  end

  def self.filter(params)
    if genre_ids = params[:genre_ids]
      mg_ids = []
      movie_ids = []
      genre_ids.each { |id| mg_ids.push(*Genre.find(id).movie_genre_ids) }
      movie_ids = mg_ids.each { |id| movie_ids.push(*MovieGenre.find(id).movie.id) }
      where(id: movie_ids)
    else
      all
    end
  end

  def self.unlinked
    where(similar_ids: nil).count
  end
end
