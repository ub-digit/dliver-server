Rails.application.routes.draw do

  resources :session

  get '/assets/:package_name/file/:file_id' => 'assets#file'
  namespace :v1, :defaults => {:format => :json} do
    resources :mets_packages, param: :name
    # User API
    resources :users
    # Link API
    resources :links, param: :link_hash

  end

end
