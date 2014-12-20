class CreateVerificates < ActiveRecord::Migration
  def change
    create_table :verificates do |t|
      t.integer  :number
      t.string   :state
      t.datetime :posting_date
      t.string   :description
      t.integer  :organization_id
      t.integer  :accounting_period_id
      t.integer  :template_id
      t.timestamps
    end
  end
end
