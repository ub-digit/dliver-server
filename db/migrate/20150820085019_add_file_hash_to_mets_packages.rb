class AddFileHashToMetsPackages < ActiveRecord::Migration
  def change
    add_column :mets_packages, :xmlhash, :text
  end
end
