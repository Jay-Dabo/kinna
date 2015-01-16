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
  has_many :accounting_periods

  validates :name, presence: true, uniqueness: {scope: :organization_id}

  def can_delete?
    return false if accounting_periods.size > 0
    true
  end
end
