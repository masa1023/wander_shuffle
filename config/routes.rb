Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "users#index"
  post "users/shuffle" => "users#shuffle"
  get "users/share_attendees" => "users#share_attendees"
  resources :users
end
