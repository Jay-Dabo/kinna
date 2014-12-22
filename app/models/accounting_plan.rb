class AccountingPlan < ActiveRecord::Base
  # t.string   :name
  # t.string   :description
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :name, :description

  belongs_to :organization
  has_many :accounting_classes, dependent: :destroy
  has_many :accounting_groups, dependent: :destroy
  has_many :accounts, dependent: :destroy

  validates :name, presence: true, uniqueness: {scope: :organization_id}

  def active?
    return true if organization.accounting_plan_id == self.id
    false
  end

  def can_delete?
    true
  end
end
