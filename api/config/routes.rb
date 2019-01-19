Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'artists/index_json', to: 'artists#index_json'
  get 'artists/show_json/:id', to: 'artists#show_json'
  resources :artists
end
