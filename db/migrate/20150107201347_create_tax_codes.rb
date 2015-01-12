class CreateTaxCodes < ActiveRecord::Migration
  def change
    create_table :tax_codes do |t|
      t.integer  :code
      t.string   :text
      t.string   :sum_method
      t.string   :code_type
      t.integer  :organization_id
      t.timestamps
    end
  end
end
