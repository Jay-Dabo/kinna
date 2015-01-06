class Account < ActiveRecord::Base
  # t.string   :number
  # t.string   :description
  # t.integer  :tax_base
  # t.integer  :tax_code
  # t.integer  :ink4
  # t.integer  :organization_id
  # t.integer  :accounting_plan_id
  # t.integer  :accounting_class_id
  # t.integer  :accounting_group_id
  # t.timestamps

  attr_accessible :number, :description, :tax_base, :tax_code, :ink4

  belongs_to :organization
  belongs_to :accounting_plan
  belongs_to :accounting_class
  belongs_to :accounting_group

  validates :number, presence: true, uniqueness: {scope: [:organization_id, :accounting_plan]}
  validates :description, presence: true

  delegate :name, :number, to: :accounting_class, prefix: :class

  def name
    number
  end

  def can_delete?
    true
  end
end
