class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer  :number
      t.string   :name
      t.integer  :organization_id
      t.integer  :accounting_plan_id
      t.timestamps
    end
  end
end
