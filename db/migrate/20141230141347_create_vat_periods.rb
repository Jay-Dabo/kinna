class CreateVatPeriods < ActiveRecord::Migration
  def change
    create_table :vat_periods do |t|
      t.string   :name
      t.datetime :vat_from
      t.datetime :vat_to
      t.datetime :deadline
      t.string   :state
      t.datetime :calculated_at
      t.datetime :reported_at
      t.datetime :closed_at
      t.integer  :organization_id
      t.integer  :accounting_period_id

      t.timestamps
    end
  end
end
