json.extract! movie, :id, :title, :tmdb_id, :imdb_id, :overview, :keywords, :tagline, :poster_path, :created_at, :updated_at
json.url movie_url(movie, format: :json)
