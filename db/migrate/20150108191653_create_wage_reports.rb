class CreateWageReports < ActiveRecord::Migration
  def change
    create_table :wage_reports do |t|
      t.integer  :amount
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.integer  :wage_period_id
      t.integer  :tax_code_id
      t.timestamps
    end
  end
end
