Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, controllers: { sessions: 'users/sessions' }, path: ''
  root to: 'movies#index'
  resources :source_apis do
    post 'load_dump'
    post 'update_with_details'
  end
  resources :movies
  post 'dump_genres' => 'genres#batch_create'
  post 'find_similar_movies' => 'movies#find_similar'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
