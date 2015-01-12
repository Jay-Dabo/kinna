class TaxCode < ActiveRecord::Base
  # t.integer  :code
  # t.string   :text
  # t.string   :sum_method
  # t.string   :code_type
  # t.integer  :organization_id

  attr_accessible :code, :text, :sum_method, :code_type

  belongs_to :organization

  SUM_METHODS = ['accounting_period', 'vat_period', 'total', 'wage_period', 'subset_55','subset_56','subset_57',
                 'subset_58', 'subset_59', 'subset_60', 'include_81']
  CODE_TYPES = ['vat', 'wage']

  validates :code, presence: true, uniqueness: {scope: :organization_id}
  validates :text, presence: true
  validates :sum_method, inclusion: { in: SUM_METHODS }
  validates :code_type, inclusion: { in: CODE_TYPES }

  scope :vat, -> { where(code_type: 'vat') }
  scope :wage, -> { where(code_type: 'wage') }

  def name
    text
  end

  def can_delete?
    true
  end
end
