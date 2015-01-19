class CreateImportBankFiles < ActiveRecord::Migration
  def change
    create_table :import_bank_files do |t|
      t.datetime :import_date
      t.datetime :from_date
      t.datetime :to_date
      t.string   :reference
      t.integer  :organization_id
      t.timestamps
    end
  end
end
