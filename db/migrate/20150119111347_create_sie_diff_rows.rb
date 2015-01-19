class CreateSieDiffRows < ActiveRecord::Migration
  def change
    create_table :sie_diff_rows do |t|
      t.integer  :old_number
      t.integer  :new_number
      t.integer  :organization_id
      t.timestamps
    end
  end
end
