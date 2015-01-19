class CreateImportBankFileRows < ActiveRecord::Migration
  def change
    create_table :import_bank_file_rows do |t|
      t.datetime :posting_date
      t.decimal  :amount, precision: 9, scale: 2
      t.string   :bank_account
      t.string   :name
      t.string   :reference
      t.decimal  :bank_balance, precision: 11, scale: 2
      t.string   :note
      t.boolean  :posted
      t.integer  :organization_id
      t.integer  :import_bank_file_id
      t.timestamps
    end
  end
end
