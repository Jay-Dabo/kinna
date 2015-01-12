class CreateWages < ActiveRecord::Migration
  def change
    create_table :wages do |t|
      t.datetime :wage_from
      t.datetime :wage_to
      t.datetime :payment_date
      t.decimal  :salary, precision: 9, scale: 2
      t.decimal  :addition, precision: 9, scale: 2
      t.decimal  :discount, precision: 9, scale: 2
      t.decimal  :tax, precision: 9, scale: 2
      t.decimal  :payroll_tax, precision: 9, scale: 2
      t.decimal  :amount, precision: 9, scale: 2
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.integer  :wage_period_id
      t.integer  :employee_id

      t.timestamps
    end
  end
end
