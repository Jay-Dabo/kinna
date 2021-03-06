class CreateOpeningBalanceItems < ActiveRecord::Migration
  def change
    create_table :opening_balance_items do |t|
      t.integer  :account_id
      t.string   :description
      t.decimal  :debit, precision: 11, scale: 2
      t.decimal  :credit, precision: 11, scale: 2
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.integer  :opening_balance_id
      t.timestamps
    end
  end
end
