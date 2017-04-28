require "rinruby"

class Quanteda
  def self.run(movie_id)
    all_movies = Movie.all.dup.freeze
    movies = all_movies.pluck(:overview, :keywords).map { |m| m.join(' ') }
    id_index = all_movies.pluck(:id).index(movie_id) + 1
    # r = RinRuby.new(echo: false)
    R.assign("input", movies)
    R.assign("id_index", id_index)
    R.eval <<EOF
      require(quanteda)
      
      inaugCorpus <- corpus(input)
      myDfm <- dfm(inaugCorpus, verbose = FALSE)
      ts = textstat_simil(myDfm, docnames(myDfm), margin = "documents", method = "cosine")
      indicies = order(ts[,id_index], decreasing = TRUE)[-1]
EOF
    indicies = R.indicies
    indicies.map! { |i| i-1 }
    indicies.map { |i| all_movies[i] }
  end
end