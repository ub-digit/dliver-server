class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.text :package_name
      t.text :link_hash
      t.date :expire_date
      t.text :note

      t.timestamps null: false
    end
  end
end
