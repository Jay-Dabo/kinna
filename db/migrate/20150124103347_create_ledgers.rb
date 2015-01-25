class CreateLedgers < ActiveRecord::Migration
  def change
    create_table :ledgers do |t|
      t.string   :name
      t.integer  :organization_id
      t.integer  :accounting_period_id

      t.timestamps
    end
  end
end
