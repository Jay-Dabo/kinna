class CreateAccountingPlans < ActiveRecord::Migration
  def change
    create_table :accounting_plans do |t|
      t.string   :name
      t.string   :description
      t.integer  :organization_id
      t.timestamps
    end
  end
end
