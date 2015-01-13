class CreateResultUnits < ActiveRecord::Migration
  def change
    create_table :result_units do |t|
      t.string   :name
      t.integer  :organization_id
      t.timestamps
    end
  end
end
