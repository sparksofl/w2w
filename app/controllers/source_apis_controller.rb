class SourceApisController < ApplicationController
  before_action :set_source_api, only: [:show, :edit, :update, :destroy, :load_dump]

  def load_dump
    movies = MoviesDumpLoader.load
    Movie.batch_create(movies)
    redirect_to movies_path
  end

  # GET /source_apis
  # GET /source_apis.json
  def index
    @source_apis = SourceApi.all
  end

  # GET /source_apis/1
  # GET /source_apis/1.json
  def show
  end

  # GET /source_apis/new
  def new
    @source_api = SourceApi.new
  end

  # GET /source_apis/1/edit
  def edit
  end

  # POST /source_apis
  # POST /source_apis.json
  def create
    @source_api = SourceApi.new(source_api_params)

    respond_to do |format|
      if @source_api.save
        format.html { redirect_to @source_api, notice: 'Source api was successfully created.' }
        format.json { render :show, status: :created, location: @source_api }
      else
        format.html { render :new }
        format.json { render json: @source_api.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /source_apis/1
  # PATCH/PUT /source_apis/1.json
  def update
    respond_to do |format|
      if @source_api.update(source_api_params)
        format.html { redirect_to @source_api, notice: 'Source api was successfully updated.' }
        format.json { render :show, status: :ok, location: @source_api }
      else
        format.html { render :edit }
        format.json { render json: @source_api.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /source_apis/1
  # DELETE /source_apis/1.json
  def destroy
    @source_api.destroy
    respond_to do |format|
      format.html { redirect_to source_apis_url, notice: 'Source api was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_source_api
      id = params[:id] || params[:source_api_id]
      @source_api = SourceApi.find(id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def source_api_params
      params.require(:source_api).permit(:name, :access_url, :website, :default)
    end
end
