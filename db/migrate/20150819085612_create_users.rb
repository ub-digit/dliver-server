class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.text :username
      t.text :name
      t.text :email
      t.timestamp :deleted_at
      t.text :role

      t.timestamps null: false
    end
  end
end
