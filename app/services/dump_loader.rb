require 'wikipedia'

class DumpLoader
  def self.load
    # randoms = Tmdb::Movie.top_rated.map(&:id).map { |id| Tmdb::Movie.detail(id)  }
    randoms = []
    (5..50).each do |i|
      randoms.push(*Tmdb::Movie.popular(page: i)[:results])
    end
    # randoms.map { |movie| Tmdb::Movie.detail(movie[:id]) }
    randoms
  end

  def self.update_with_details
    Movie.all.each do |movie|
      details = Tmdb::Movie.detail(movie.tmdb_id)
      details = details.to_h.slice(*Movie.attribute_names.map(&:to_sym) - [:poster_path])
      genres = details[:genres].dup
      details[:genres] = details[:genres].map(&:name).join(', ')
      genres.map(&:id).each do |ext_id|
        genre = Genre.find_by(tmdb_id: ext_id)
        mg = MovieGenre.create(movie_id: movie.id,
                          genre_id: genre.id)
        genre.movie_genres << mg
        movie.movie_genres << mg
        genre.save
      end
      movie.update(details)
    end
  end

  def self.update_via_wiki
    Movie.all.each do |movie|
      begin
        page = Wikipedia.find( movie.title)
        next unless page.text
        next if movie.desc
        movie.update(desc: page.text)
      rescue
        next
      end
    end
  end

  def self.load_genres
    genres = Tmdb::Genre.movie_list
    genres.map! do |genre|
      { tmdb_id: genre.id, name: genre.name }
    end
  end

  def self.rand_n(n, max)
    randoms = Set.new
    loop do
      randoms << rand(max)
      return randoms.to_a if randoms.size >= n
    end
  end
end