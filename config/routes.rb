Rails.application.routes.draw do
  post '/locations/submit'
  get  '/locations/data'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #resources :locations, only: :index
end
