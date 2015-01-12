class Template < ActiveRecord::Base
  # t.string   :name
  # t.string   :description
  # t.integer  :organization_id
  # t.integer  :accounting_plan_id
  # t.timestamps

  attr_accessible :name, :description, :accounting_plan, :accounting_plan_id

  belongs_to :organization
  belongs_to :accounting_plan
  has_many   :template_items, dependent: :destroy

  validates :name, presence: true
  validates :accounting_plan, presence: true

  def can_delete?
    true
  end
end
