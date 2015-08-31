class AddTypeOfRecordToMetsPackage < ActiveRecord::Migration
  def change
    add_column :mets_packages, :type_of_record, :text, default: [], array: true
  end
end
