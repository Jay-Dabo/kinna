class CreateTaxReturns < ActiveRecord::Migration
  def change
    create_table :tax_returns do |t|
      t.string   :name
      t.datetime :deadline
      t.string   :state
      t.datetime :calculated_at
      t.datetime :reported_at
      t.integer  :organization_id
      t.integer  :accounting_period_id

      t.timestamps
    end
  end
end
