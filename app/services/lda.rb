require "rinruby"

class Lda
  def self.run
    movies = Movie.pluck(:overview)
    titles = Movie.pluck(:title)

    r = RinRuby.new(echo: false)
    r.movies = movies
    r.titles = titles
    r.eval <<EOF
      
      require(reshape2)
      library(RTextTools)
      library(topicmodels)

      titles <- c(titles)
      movies <- c(movies)
      my.frame <- data.frame(titles, movies)
      colnames(my.frame) <- c('titles', 'movies')

      matrix <- create_matrix(cbind(as.vector(data$Title),as.vector(data$Subject)), language="english", removeNumbers=TRUE, stemWords=TRUE, weighting=weightTf)
      k <- length(unique(data$Topic.Code))
      lda <- LDA(matrix, k)
      terms(lda)
EOF
  end
end