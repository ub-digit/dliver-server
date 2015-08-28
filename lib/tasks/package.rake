namespace :package do
  desc "Traverse and sync packages"

  task :setup => :environment do
    Rails.application.eager_load!
  end

  task :sync => :setup do
    MetsPackage.sync
  end
end
