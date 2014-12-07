class OrganizationRole < ActiveRecord::Base
  # t.string  :name, null: false
  # t.integer :user_id, null: false
  # t.integer :organization_id, null: false
  # add_index :organization_roles,
  #           [:name, :user_id, :organization_id],
  #           unique: true,
  #           name: :organization_roles_index

  ALL_ROLES    = [ROLE_ADMIN = 'admin',
                  ROLE_STAFF = 'staff',
                  ROLE_SUPERADMIN = 'superadmin',
                  ROLE_SUSPENDED = 'suspended']
  ROLES        = [ROLE_ADMIN, ROLE_STAFF, ROLE_SUSPENDED]
  ACCESS_ROLES = [ROLE_ADMIN, ROLE_STAFF]

  scope :roles_with_access, -> { where('name in (?)', [ROLE_STAFF, ROLE_ADMIN]) }

  belongs_to :user
  belongs_to :organization

  attr_accessible :name, :user_id

  validates :name, presence: true, inclusion: { in: ALL_ROLES }
end
