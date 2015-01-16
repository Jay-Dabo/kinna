class TaxCode < ActiveRecord::Base
  # t.integer  :code
  # t.string   :text
  # t.string   :sum_method
  # t.string   :code_type
  # t.integer  :organization_id

  attr_accessible :code, :text, :sum_method, :code_type

  belongs_to :organization
  has_many   :accounts

  SUM_METHODS = ['accounting_period', 'vat_period', 'total', 'wage_period', 'subset_55','subset_56','subset_57',
                 'subset_58', 'subset_59', 'subset_60', 'include_81', 'none']
  CODE_TYPES = ['vat', 'wage', 'default']

  validates :code, presence: true, uniqueness: {scope: :organization_id}
  validates :text, presence: true
  validates :sum_method, inclusion: { in: SUM_METHODS }
  validates :code_type, inclusion: { in: CODE_TYPES }

  scope :vat, -> { where(code_type: 'vat') }
  scope :wage, -> { where(code_type: 'wage') }
  scope :default, -> { where(code_type: 'default') }

  def name
    text
  end

  def can_delete?
    return false if accounts.size > 0
    return false if self.sum_method == 'total'
    return false if self.code_type == 'default'
    true
  end
end
