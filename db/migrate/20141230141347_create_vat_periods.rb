class CreateVatPeriods < ActiveRecord::Migration
  def change
    create_table :vat_periods do |t|
      t.string   :name
      t.datetime :vat_from
      t.datetime :vat_to
      t.datetime :deadline
      t.decimal  :box_05, precision: 11, scale: 2
      t.decimal  :box_10, precision: 11, scale: 2
      t.decimal  :box_11, precision: 11, scale: 2
      t.decimal  :box_12, precision: 11, scale: 2
      t.decimal  :box_48, precision: 11, scale: 2
      t.decimal  :box_49, precision: 11, scale: 2
      t.string   :state
      t.datetime :calculated_at
      t.datetime :reported_at
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.integer  :verificate_id

      t.timestamps
    end
  end
end
