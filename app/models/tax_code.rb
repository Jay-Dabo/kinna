class TaxCode < ActiveRecord::Base
  # t.integer  :code
  # t.string   :text
  # t.string   :sum_method
  # t.integer  :organization_id

  attr_accessible :code, :text, :sum_method

  belongs_to :organization

  SUM_METHODS = ['accounting_period', 'vat_period', 'total']

  validates :code, presence: true, uniqueness: {scope: :organization_id}
  validates :text, presence: true
  validates :sum_method, inclusion: { in: SUM_METHODS }



  def name
    text
  end

  def can_delete?
    true
  end
end
