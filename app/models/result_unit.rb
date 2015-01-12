class ResultUnit < ActiveRecord::Base
  # t.integer  :name
  # t.integer  :organization_id

  attr_accessible :name

  belongs_to :organization

  validates :name, presence: true, uniqueness: {scope: :organization_id}

  def can_delete?
    true
  end
end
