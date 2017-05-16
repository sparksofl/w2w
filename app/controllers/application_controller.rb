class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :generate_rand_title

  def authenticate_admin_user!
    redirect_to new_new_registration_path unless current_user.try(:admin?)
  end

  def generate_rand_title
    @rand_title = '' # Movie.skip(rand(Movie.count)).first.title
  end
end
