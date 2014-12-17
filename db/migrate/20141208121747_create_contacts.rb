class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :organization_id

      t.string  :name
      t.string  :email
      t.string  :telephone
      t.string  :address
      t.string  :zip
      t.string  :city
      t.string  :country
      t.text    :comment

      t.timestamps
    end

    add_index :contacts, [:email, :organization_id], unique: true
  end
end
