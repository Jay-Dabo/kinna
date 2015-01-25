class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.integer  :number
      t.string   :description
      t.integer  :organization_id
      t.integer  :accounting_plan_id
      t.integer  :accounting_class_id
      t.integer  :accounting_group_id
      t.integer  :tax_code_id
      t.integer  :ink_code_id
      t.timestamps
    end
  end
end
