class CreateAccountingGroups < ActiveRecord::Migration
  def change
    create_table :accounting_groups do |t|
      t.string   :number
      t.string   :name
      t.integer  :organization_id
      t.integer  :accounting_plan_id

      t.timestamps
    end
  end
end
