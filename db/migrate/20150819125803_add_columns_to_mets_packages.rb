class AddColumnsToMetsPackages < ActiveRecord::Migration
  def change
    add_column :mets_packages, :title, :text
    add_column :mets_packages, :sub_title, :text
    add_column :mets_packages, :author, :text
    add_column :mets_packages, :year, :text
    add_column :mets_packages, :search_string, :text
  end
end
