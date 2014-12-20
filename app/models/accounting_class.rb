class AccountingClass < ActiveRecord::Base
  # t.string   :number
  # t.string   :name
  # t.integer  :organization_id
  # t.integer  :accounting_plan_id
  # t.timestamps

  attr_accessible :number, :name

  belongs_to :organization
  belongs_to :accounting_plan
  has_many   :accounts

  validates :number, presence: true
  validates :name, presence: true

  def can_delete?
    true
  end
end
