Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    resources :appointments, only: [:index]
    get "doctors", to: "doctors#free"
  end
end