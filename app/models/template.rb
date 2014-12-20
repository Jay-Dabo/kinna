class Template < ActiveRecord::Base
  # t.string   :name
  # t.string   :description
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :name, :description

  belongs_to :organization
  has_many   :template_items, dependent: :destroy

  validates :name, presence: true

  def can_delete?
    true
  end
end
