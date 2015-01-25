class CreateOpeningBalances < ActiveRecord::Migration
  def change
    create_table :opening_balances do |t|
      t.string   :description
      t.string   :state
      t.datetime :posting_date
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.timestamps
    end
  end
end
