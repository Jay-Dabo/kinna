class AccountingGroup < ActiveRecord::Base
  # t.string   :number
  # t.string   :name
  # t.integer  :organization_id
  # t.integer  :accounting_plan_id
  # t.timestamps

  attr_accessible :number, :name

  belongs_to :organization
  belongs_to :accounting_plan
  has_many   :accounts

  validates :number, presence: true, uniqueness: {scope: [:organization_id, :accounting_plan]}
  validates :name, presence: true

  def can_delete?
    return false if accounts.size > 0
    true
  end
end
