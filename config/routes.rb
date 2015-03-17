Rails.application.routes.draw do

  resources :sites

  root 'sites#index'

  get 'search', to: 'search#search'
  post 'reload', to: 'sites#reload'

end
