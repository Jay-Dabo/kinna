class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string   :name
      t.datetime :begin
      t.datetime :end
      t.integer  :organization_id

      t.timestamps
    end
  end
end
