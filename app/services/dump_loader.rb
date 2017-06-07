require 'wikipedia'

class DumpLoader
  def self.load
    # randoms = Tmdb::Movie.top_rated.map(&:id).map { |id| Tmdb::Movie.detail(id)  }
    randoms = []
    (1..50).each do |i|
      randoms.push(*Tmdb::Movie.popular(page: i)[:results])
    end
    # randoms.map { |movie| Tmdb::Movie.detail(movie[:id]) }
    randoms
  end

  def self.update_with_details
    Movie.all.each do |movie|
      details = Tmdb::Movie.detail(movie.tmdb_id)
      genres = details[:genres].dup
      details = details.to_h.slice(*Movie.attribute_names.map(&:to_sym) - [:poster_path])
      # details[:genres] = details[:genres].map(&:name).join(', ')
      genres.map(&:id).each do |ext_id|
        genre = Genre.find_by(tmdb_id: ext_id)
        movie.genres << genre
        genre.movies << movie
      end
      movie.update(details)
    end
  end

  def self.update_via_wiki
    Movie.where(desc: nil).each do |movie|
      page = Wikipedia.find(movie.title)
      page = Wikipedia.find("#{movie.title} (film)") unless movie_plot(page.text)
      next unless page.text
      movie.update(desc: movie_plot(page.text))
    end
  end

  def self.load_genres
    genres = Tmdb::Genre.movie_list
    genres.map! do |genre|
      { tmdb_id: genre.id, name: genre.name }
    end
  end

  def self.load_actors
    Movie.all.each do |movie|
      cast = Tmdb::Movie.cast(movie.tmdb_id)
      cast.each { |c| actor = Actor.create(name: c.name); movie.actors << actor }
    end
  end

  def self.update_keywords
    Movie.all.each do |m|
      m.keywords.split(', ').each do |w|
        if k = Keyword.find_by(name: w)
          k.movie_ids << m.id
        else
          Keyword.create(name: w, movie_ids: [m.id])
        end
      end
    end
  end

  def self.rand_n(n, max)
    randoms = Set.new
    loop do
      randoms << rand(max)
      return randoms.to_a if randoms.size >= n
    end
  end

  def movie_plot(text)
    return unless text
    str1_markerstring = "== Plot"
    str1_alt_markerstring = "== Setting"
    str2_markerstring = "\n\n\n=="
    input_string = text
    res = input_string[/#{str1_markerstring}(.*?)#{str2_markerstring}/m, 1]
    res = input_string[/#{str1_alt_markerstring}(.*?)#{str2_markerstring}/m, 1] if res.nil?
    res
  end
end
