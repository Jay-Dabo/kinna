class Conversion < ActiveRecord::Base
  # t.integer  :old_number
  # t.integer  :new_number
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :old_number, :new_number

  belongs_to :organization

  def can_delete?
    true
  end
end
