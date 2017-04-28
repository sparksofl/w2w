class MoviesDumpLoader
  def self.load
    # randoms = Tmdb::Movie.top_rated.map(&:id).map { |id| Tmdb::Movie.detail(id)  }
    randoms = []
    (1..11).each do |i|
      randoms.push(*Tmdb::Movie.popular(page: i)[:results].flat_map(&:id))
    end
    # TODO: use api_source param to request data from different resources
    # movie[:keywords] = Tmdb::Movie.keywords(p['id'])['keywords'].each.map { |h| h['name'] }.join(' ')
    randoms.map { |id| Tmdb::Movie.detail(id) }
  end

  def self.rand_n(n, max)
    randoms = Set.new
    loop do
      randoms << rand(max)
      return randoms.to_a if randoms.size >= n
    end
  end
end