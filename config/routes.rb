Rails.application.routes.draw do

  resources :session

  get '/assets/:package_name/file/:file_id' => 'assets#file'
  namespace :v1, :defaults => {:format => :json} do

    # Config API
    get 'config/role_list', to: 'config#role_list'

    # Mets Package API
    resources :mets_packages, param: :package_name
    get 'mets_packages/:package_name/thumbnail', to: 'mets_packages#thumbnail'

    # User API
    resources :users

    # Link API
    resources :links, param: :link_hash
  end

end
