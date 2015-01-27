class CreateConversions < ActiveRecord::Migration
  def change
    create_table :conversions do |t|
      t.integer  :old_number
      t.integer  :new_number
      t.integer  :organization_id
      t.timestamps
    end
  end
end
