class CreateClosingBalances < ActiveRecord::Migration
  def change
    create_table :closing_balances do |t|
      t.datetime :posting_date
      t.string   :description
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.timestamps
    end
  end
end
