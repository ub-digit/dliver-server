namespace :package do
  desc "Traverse and sync packages"
  task sync: :environment do
    MetsPackage.sync
  end
end
