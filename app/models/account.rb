class Account < ActiveRecord::Base
  # t.string   :number
  # t.string   :description
  # t.integer  :tax_code_id
  # t.integer  :ink_code_id
  # t.integer  :organization_id
  # t.integer  :accounting_plan_id
  # t.integer  :accounting_class_id
  # t.integer  :accounting_group_id
  # t.timestamps

  attr_accessible :number, :description, :tax_code_id, :ink4

  belongs_to :organization
  belongs_to :accounting_plan
  belongs_to :accounting_class
  belongs_to :accounting_group
  belongs_to :tax_code
  belongs_to :ink_code
  has_many   :opening_balance_items
  has_many   :verificate_items
  has_many   :closing_balance_items

  validates :number, presence: true, uniqueness: {scope: [:organization_id, :accounting_plan]}
  validates :description, presence: true

  delegate :name, :number, to: :accounting_class, prefix: :class

  def name
    number
  end

  def can_delete?
    return false if opening_balance_items.size > 0
    return false if verificate_items.size > 0
    return false if closing_balance_items.size > 0
    true
  end
end
