class CreateTemplateItems < ActiveRecord::Migration
  def change
    create_table :template_items do |t|
      t.integer  :account_id
      t.string   :description
      t.boolean  :enable_debit
      t.boolean  :enable_credit
      t.integer  :organization_id
      t.integer  :template_id
      t.timestamps
    end
  end
end
