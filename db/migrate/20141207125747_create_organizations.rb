class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :slug, null: false, unique: true
      t.string :email
      t.string :name
      t.string :address
      t.string :zip
      t.string :city
      t.string :vat_number
      t.string :bankgiro
      t.string :postgiro
      t.string :plusgiro
      t.string :swift
      t.string :iban

      t.timestamps
    end
  end
end
