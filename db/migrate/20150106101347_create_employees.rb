class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.string   :name
      t.integer  :birth_year
      t.datetime :begin
      t.datetime :ending
      t.decimal  :salary, precision: 6, scale: 0
      t.decimal  :tax, precision: 6, scale: 0
      t.integer  :organization_id

      t.timestamps
    end
  end
end
