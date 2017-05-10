class GenresController < ApplicationController
    def batch_create
      Genre.batch_create(DumpLoader.load_genres)
      redirect_to root_path
    end
end
