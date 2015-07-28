class CreateMetsPackages < ActiveRecord::Migration
  def change
    create_table :mets_packages do |t|
      t.string "name"
      t.text "xml"
      t.text "metadata"

      t.timestamps null: false
    end
  end
end
