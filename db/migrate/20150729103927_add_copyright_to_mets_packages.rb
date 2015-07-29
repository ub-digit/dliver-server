class AddCopyrightToMetsPackages < ActiveRecord::Migration
  def change
    add_column :mets_packages, :copyrighted, :boolean
  end
end
