class CreateInkCodes < ActiveRecord::Migration
  def change
    create_table :ink_codes do |t|
      t.string   :code
      t.string   :text
      t.string   :sum_method
      t.string   :bas_accounts
      t.integer  :organization_id
      t.timestamps
    end
  end
end
