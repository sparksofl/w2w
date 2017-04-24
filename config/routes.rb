Rails.application.routes.draw do
  root to: 'movies#index'
  resources :source_apis do
    post 'load_dump'
  end
  resources :movies
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
