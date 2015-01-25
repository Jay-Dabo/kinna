class CreateLedgerAccounts < ActiveRecord::Migration
  def change
    create_table :ledger_accounts do |t|
      t.string   :name
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.integer  :ledger_id
      t.integer  :account_id
      t.decimal  :sum, precision: 11, scale: 2

      t.timestamps
    end
  end
end
