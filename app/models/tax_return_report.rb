class TaxReturnReport < ActiveRecord::Base
  # t.integer  :amount
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :tax_return_id
  # t.integer  :ink_code_id
  # t.timestamps


  attr_accessible :amount, :accounting_period_id, :ink_code_id

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :tax_return
  belongs_to :ink_code

  validates :accounting_period, presence: true
  validates :ink_code, presence: true

  def name
    'cc'
  end

  def can_delete?
    return true if tax_return.can_calculate?
    false
  end
end
