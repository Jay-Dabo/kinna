class VatReport < ActiveRecord::Base
  # t.integer  :amount
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :vat_period_id
  # t.integer  :tax_code_id
  # t.timestamps


  attr_accessible :amount, :accounting_period_id, :vat_period_id, :tax_code_id

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :vat_period
  belongs_to :tax_code

  validates :accounting_period, presence: true
  validates :vat_period, presence: true
  validates :tax_code, presence: true

  def can_delete?
    return true if vat_period.can_calculate?
    false
  end
end
