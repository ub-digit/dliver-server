Rails.application.routes.draw do

  namespace :v1, :defaults => {:format => :json} do
    resources :mets_packages
  end

end
