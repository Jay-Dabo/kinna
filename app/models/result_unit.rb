class ResultUnit < ActiveRecord::Base
  # t.integer  :name
  # t.integer  :organization_id

  attr_accessible :name

  belongs_to :organization
  has_many   :verificate_items

  validates :name, presence: true, uniqueness: {scope: :organization_id}

  def can_delete?
    return false if verificate_items.size > 0
    true
  end
end
