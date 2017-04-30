class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def authenticate_admin_user!
    redirect_to new_new_registration_path unless current_user.try(:admin?)
  end
end
