require "rinruby"

class Lsa
  def self.process_movies
    movies = Movie.pluck(:overview)
    counter = movies.count
    titles = Movie.pluck(:title)
    r = RinRuby.new(:echo => false)
    r.assign("input", movies)
    r.assign "counter", counter
    r.assign "titles", titles
    r.eval <<EOF
      library(tm)
      library(ggplot2)
      library(lsa)
      library(scatterplot3d)
      library(SnowballC)

      text <- c(input)
      names <- paste("var",c(1:counter),sep="") 
      view <- factor(rep(titles, each = 2))
      view
      df <- data.frame(text, view, stringsAsFactors = FALSE)
      df
      
      
      
      #------------------------------------------------------------------------------
      
      # prepare corpus
      corpus <- Corpus(VectorSource(df$text))
      corpus <- tm_map(corpus, PlainTextDocument)
      corpus <- tm_map(corpus, tolower)
      corpus <- tm_map(corpus, removePunctuation)
      corpus <- tm_map(corpus, function(x) removeWords(x, stopwords("english")))
      
      # error below, can't stem
      corpus  <- tm_map(corpus, stemDocument, language = "english") 
      corpus  
      
      
      
      #------------------------------------------------------------------------------
      
      # MDS with raw term-document matrix compute distance matrix
      td.mat <- as.matrix(TermDocumentMatrix(corpus))
      td.mat
      dist.mat <- dist(t(as.matrix(td.mat)))
      dist.mat  # check distance matrix
      
      
      
      #------------------------------------------------------------------------------
      
      # MDS
      fit <- cmdscale(dist.mat, eig = TRUE, k = 2)
      points <- data.frame(x = fit$points[, 1], y = fit$points[, 2])
      ggplot(points, aes(x = x, y = y)) + geom_point(data = points, aes(x = x, y = y, 
          color = df$view)) + geom_text(data = points, aes(x = x, y = y - 0.2, label = 
          row.names(df)))
      
      
      
      
      #------------------------------------------------------------------------------
      
      # MDS with LSA
      td.mat.lsa <- lw_bintf(td.mat) * gw_idf(td.mat)  # weighting
      lsaSpace <- lsa(td.mat.lsa)  # create LSA space
      dist.mat.lsa <- dist(t(as.textmatrix(lsaSpace)))  # compute distance matrix
      dist.mat.lsa  # check distance mantrix
      
      
      #------------------------------------------------------------------------------
      
      # MDS
      fit <- cmdscale(dist.mat.lsa, eig = TRUE, k = 2)
      points <- data.frame(x = fit$points[, 1], y = fit$points[, 2])
      ggplot(points, aes(x = x, y = y)) + geom_point(data = points, aes(x = x, y = y, 
          color = df$view)) + geom_text(data = points, aes(x = x, y = y - 0.2, label = row.names(df)))
      
      
      #------------------------------------------------------------------------------
      
      # plot
      # fit <- cmdscale(dist.mat.lsa, eig = TRUE, k = 3)
      # colors <- rep(c("blue", "green", "red"), each = 3)
      # scatterplot3d(fit$points[, 1], fit$points[, 2], fit$points[, 3], color = colors, 
      #     pch = 320, main = "Semantic Space Scaled to 3D", xlab = "x", ylab = "y", 
      #     zlab = "z", type = "h")
EOF
  end
end