class CreateAccountingPeriods < ActiveRecord::Migration
  def change
    create_table :accounting_periods do |t|
      t.string   :name
      t.datetime :accounting_from
      t.datetime :accounting_to
      t.string   :vat_period_type
      t.boolean  :active
      t.integer  :organization_id
      t.integer  :accounting_plan_id
      t.timestamps
    end
  end
end
