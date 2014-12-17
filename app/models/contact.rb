class Contact < ActiveRecord::Base
  # t.integer :organization_id
  # t.string :name
  # t.string :email
  # t.string :telephone
  # t.string :address
  # t.string :zip
  # t.string :city
  # t.string :country
  # t.text :comment

  belongs_to :organization
  has_many :contact_relations

  attr_accessible :email, :name, :telephone, :address, :zip, :city, :country, :comment

  validates :name, presence: true
  validates :email, presence: true, uniqueness: {scope: :organization_id}

  VALID_PARENT_TYPES = ['Customer', 'Supplier', 'Warehouse', 'ContactRelation', 'User']

  def user_parent?
    return true if contact_relations.where("parent_type = 'User'").count > 0
    false
  end

  # For ApplicationHelper#delete_button
  def can_delete?
    return false if ContactRelation.where('contact_id=?', id).count > 0
    true
  end

  def parent_name
    parent.name
  end
end
