class CreateTaxReturnReports < ActiveRecord::Migration
  def change
    create_table :tax_return_reports do |t|
      t.integer  :amount
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.integer  :tax_return_id
      t.integer  :ink_code_id
      t.timestamps
    end
  end
end
