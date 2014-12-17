class ContactRelation < ActiveRecord::Base
  # t.integer :organization_id
  # t.string :parent_type
  # t.integer :parent_id
  # t.integer :contact_id

  belongs_to :organization
  belongs_to :contact
  belongs_to :parent, polymorphic: true

  attr_accessible :parent_type, :parent_id, :parent

  def can_delete?
    true
  end
end
