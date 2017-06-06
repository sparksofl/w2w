class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]

  def find_similar
    Quanteda.pure_run
    redirect_to root_path
  end

  # GET /movies
  # GET /movies.json
  def index
    # @movies = Movie.all
    @movies = Movie.all.search(params[:search]).filter(params).order_by('count(similar_ids) desc').page(params[:page]).per(10)
    @genres = Genre.find(params[:genre_ids]) if params[:genre_ids]
    render :index
  end

  def data
    @res
    @data = []
    movies = Movie.all.limit(50)
    movies.each do |m|
      r = {}
      r[:name] = "Title.#{m.title}"
      r[:imports] = []
      m.keywords_str.split(', ').each do |kw|
        r[:imports] << "Tag.#{kw}"
      end
      m.genres.each do |g|
        r[:imports] << "Categorie.#{g.name}"
      end
      @data << r
    end
    @data = @data.to_json
    render json: @data
  end

  def overview
    words = Movie.all.pluck(:keywords_str).join().split(', ')
    wf = Hash.new(0).tap { |h| words.each { |word| h[word] += 1 } }
    @res = []
    wf.each do |k,v|
      @res << { text: k, weight: v, link: movies_path(search: k) }
    end

    @data = []
    Movie.all.limit(250).each do |movie|
      movie.similar_ids.split(', ').each do |id|
        @data << { source: movie.title, target: Movie.find(id).title, type: 'abc' }
      end
    end
  end

  def graph
    movies = Movie.all.order_by('count(similar_ids) desc').limit(100)
    @links = []
    @nodes = movies.pluck(:title)
    movies.each do |movie|
      movie.similar_ids.split(', ')[0,5].each do |id|
        similar = Movie.find(id)
        genre = (movie.genres.pluck(:name)&similar.genres.pluck(:name))[0]
        @links << { source: movie.title, target: Movie.find(id).title, type: genre }
      end
    end
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
    movies = @movie.similar_ids.split(', ')[0,4].map { |id| Movie.find(id) }
    @links = []
    @nodes = movies.pluck(:title)
    movies.each do |movie|
      movie.similar_ids.split(', ')[0,5].each do |id|
        similar = Movie.find(id)
        genre = (movie.genres.pluck(:name)&similar.genres.pluck(:name))[0]
        @links << { source: movie.title, target: Movie.find(id).title, type: genre }
      end
    end
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:title, :tmdb_id, :imdb_id, :overview, :keywords, :tagline, :poster_path, :desc)
    end
end
