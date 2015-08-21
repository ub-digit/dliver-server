Rails.application.routes.draw do

  resources :session
  namespace :v1, :defaults => {:format => :json} do
    resources :mets_packages
    # User API
    resources :users
    # Link API
    resources :links, param: :link_hash

  end

end
