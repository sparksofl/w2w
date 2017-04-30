require "rinruby"
require "rake"

class Quanteda
  def self.run(movie_id)
    all_movies = Movie.all.dup.freeze
    movies = all_movies.pluck(:overview, :keywords).map { |m| m.join(' ') }
    id_index = all_movies.pluck(:id).map(&:to_s).index(movie_id) + 1
    r = RinRuby.new(echo: false)
    r.assign("input", movies)
    r.assign("id_index", id_index)
    r.eval <<EOF
      require(quanteda)
      
      inaugCorpus <- corpus(input)
      myDfm <- dfm(inaugCorpus, verbose = FALSE)
      ts = textstat_simil(myDfm, docnames(myDfm), margin = "documents", method = "cosine")
      indicies = order(ts[,id_index][ts[,id_index] >= 0.6], decreasing = TRUE)[-1]
EOF
    # Movie.all.each do |m|
    #   m_id = m.id
    #   R.ts.row(m_id).sort.reverse[1..-1]
    # end
    # R.ts.row(3).sort.reverse[1..-1]
    indicies = r.indicies
    indicies = [indicies] unless indicies.is_a? Array
    indicies.map! { |i| i-1 }
    indicies.map! { |i| all_movies[i].id.to_s }
    Movie.find(movie_id).update(similar_ids: indicies)
    indicies
  end

  def self.bigrun
    puts 'loading movies from the db ...'
    all_movies = Movie.all.dup.freeze
    movies = all_movies.pluck(:overview, :keywords).map { |m| m.join(' ') }
    movie_ids = all_movies.pluck(:id).map(&:to_s)
    puts 'initializing RinRuby ...'
    r = RinRuby.new(echo: false)
    puts 'assigning inputs ...'
    r.assign("input", movies)
    r.assign("movie_ids", movie_ids)
    puts 'casting magic spells ... '

    r.eval <<EOF
      require(quanteda)
      
      inaugCorpus <- corpus({input})
      names(inaugCorpus) <- c({movie_ids})
      myDfm <- dfm(inaugCorpus, verbose = FALSE)
      ts = textstat_simil(myDfm, docnames(myDfm), margin = "documents", method = "cosine")
EOF

    puts 'processing the matrix ...'
    matrix = r.ts
    all_movies.each_with_index do |m, i|
      row = matrix.row(i).reject { |el| el < 0.5 }
      movies_ids = ((Hash[(0...row.size).zip row]).sort_by { |_,v| v }).map{|el| el[0] }
      m.update(similar_ids: all_movies.values_at(*movies_ids).map{|el| el.id.to_s})
    end
    puts 'done and dusted'
  end

  def self.pure_run
    load './lib/tasks/run_r.rake'
    Rake::Task['run_r'].execute
  end
end