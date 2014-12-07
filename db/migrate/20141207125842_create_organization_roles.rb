class CreateOrganizationRoles < ActiveRecord::Migration
  def change
    create_table :organization_roles do |t|
      t.string  :name, null: false
      t.integer :user_id, null: false
      t.integer :organization_id, null: false
    end

    add_index :organization_roles, [:name, :user_id, :organization_id], unique: true, name: :organization_roles_index
  end
end
