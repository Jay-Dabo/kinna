class CreateLedgerTransactions < ActiveRecord::Migration
  def change
    create_table :ledger_transactions do |t|
      t.string   :parent_type
      t.integer  :parent_id
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.integer  :ledger_id
      t.integer  :account_id
      t.datetime :posting_date
      t.integer  :number
      t.string   :text
      t.decimal  :sum, precision: 11, scale: 2

      t.timestamps
    end
  end
end
