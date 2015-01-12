class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string   :name
      t.string   :description
      t.integer  :organization_id
      t.integer  :accounting_plan_id
      t.timestamps
    end
  end
end
