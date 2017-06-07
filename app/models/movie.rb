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
  field :similar_cs, type: String
  field :desc, type: String
  field :vote_average, type: Integer
  field :release_date, type: String
  field :keywords_str, type: String
  field :keyphrases_str, type: String
  field :processed_text, type: String

  has_and_belongs_to_many :genres
  has_and_belongs_to_many :actors
  has_and_belongs_to_many :keywords

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

  def self.all
    self.not.where(similar_ids: '')
  end

  def self.search(str)
    if str
      str = str.downcase.gsub(/'/, "'''")
      if str[0] == '#'
        str = str.gsub(/#/, "")
        pattern = /.*#{str}.*/i
        any_of({processed_text: pattern}, {title: pattern}, {desc: pattern})
      else
        pattern = /.*#{str}.*/i
        any_of({title: pattern})
      end
    else
      all
    end
  end

  def self.filter(params)
    if genre_ids = params[:genre_ids]
      # where(genre_ids: genre_ids)
      any_in({genre_ids: genre_ids})
    else
      all
    end
  end

  def self.unlinked
    where(similar_ids: nil).count
  end

  def actors_info
    actors.limit(10).map(&:name).join(', ')
  end

  def keywords_info
    "##{keywords_str}".downcase.split(', ').join(', #')
  end

  def similar_hash
    return unless similar_ids
    return unless similar_cs
    ids = similar_ids.split(', ').map(&:to_s)[0..5]
    cs = similar_cs.split(', ').map { |f| ("%5.2f" % f).to_f * 100 }[0..5]
    Hash[ids.zip cs]
  end
end
