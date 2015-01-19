class CreateVerificates < ActiveRecord::Migration
  def change
    create_table :verificates do |t|
      t.integer  :number
      t.string   :state
      t.datetime :posting_date
      t.string   :description
      t.string   :reference
      t.string   :note
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.integer  :template_id
      t.integer  :vat_period_id
      t.integer  :wage_period_wage_id
      t.integer  :wage_period_report_id
      t.integer  :import_bank_file_row_id
      t.timestamps
    end
  end
end
