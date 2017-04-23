class MoviesDumpLoader
  def self.load
    randoms = rand_n(10, 999_999)
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