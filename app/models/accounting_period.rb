class AccountingPeriod < ActiveRecord::Base
  # t.string   :name
  # t.datetime :accounting_from
  # t.datetime :accounting_to
  # t.string   :vat_period_type
  # t.boolean  :active
  # t.integer  :organization_id
  # t.integer  :accounting_plan_id
  # t.timestamps

  attr_accessible :name, :accounting_from, :accounting_to, :active, :vat_period_type, :accounting_plan, :accounting_plan_id

  belongs_to :organization
  belongs_to :accounting_plan
  has_one :opening_balance
  has_one :closing_balance
  has_many :verificates
  has_many :vat_periods, dependent: :delete_all
  has_many :wage_periods, dependent: :delete_all
  has_one  :ledger, dependent: :delete

  VAT_TYPES = ['year', 'quarter', 'month']

  validates :name, presence: true, uniqueness: {scope: :organization_id}
  validates :accounting_from, presence: true
  validates :accounting_to, presence: true
  validate :check_to
  validate :overlaping_period
  validates :vat_period_type, inclusion: { in: VAT_TYPES }

  def check_to
    if accounting_from >= accounting_to
      errors.add(:accounting_to, I18n.t(:period_error))
    end
  end

  def overlaping_period
    p = AccountingPeriod.where('organization_id = ? and accounting_to >= ? and accounting_from <= ?' , organization_id, accounting_from, accounting_to).count
    if new_record?
      errors.add(:accounting_to, I18n.t(:within_period)) if p > 0
    else
      errors.add(:accounting_to, I18n.t(:within_period)) if p > 1
    end
  end

  after_create :create_dependent

  def create_dependent
    ledger = Ledger.new
    ledger.name =  'Huvudbok ' + accounting_from.strftime('%Y')
    ledger.accounting_period = self
    ledger.organization = organization
    ledger.save
  end

  def allow_from
    return accounting_from if verificates.where("state = 'final'").count == 0
    verificates.where("state = 'final'").maximum(:posting_date)
  end

  def allow_to
    return accounting_to if DateTime.now > accounting_to
    DateTime.now
  end

  def previous_accounting_period
    organization.accounting_periods.where('accounting_from < ? and accounting_to > ?', accounting_from-10.day,accounting_from-10.day ).first
  end

  def next_vat_period
    vat_period = VatPeriod.new
    vat_period.accounting_period_id = self.id
    vat_period.name = 'Momsperiod ' + accounting_from.strftime('%Y') + ':' + (vat_periods.count + 1).to_s
    vat_period.vat_from = vat_periods.count > 0 ? vat_periods.last.vat_to + 1.days : accounting_from
    case vat_period_type
      when 'year'
        vat_period.vat_to = vat_period.vat_from + 1.year - 1.days
        vat_period.deadline = vat_period.vat_to + 1.month + 26.days
      when 'quarter'
        vat_period.vat_to = vat_period.vat_from + 3.month - 1.days
        vat_period.deadline = vat_period.vat_to + 1.month + 12.days
      when 'month'
        vat_period.vat_to = vat_period.vat_from.end_of_month
        vat_period.deadline = vat_period.vat_to + 1.month + 12.days
    end
    return vat_period
  end

  def next_wage_period
    wage_period = WagePeriod.new
    wage_period.accounting_period_id = self.id
    wage_period.name = 'Löneperiod ' + accounting_from.strftime('%Y') + ':' + (wage_periods.count + 1).to_s
    wage_period.wage_from = wage_periods.count > 0 ? wage_periods.last.wage_to + 1.days : accounting_from
    wage_period.wage_to = wage_period.wage_from.end_of_month
    wage_period.payment_date = wage_period.wage_from + 17.days
    wage_period.deadline = wage_period.wage_to + 12.days
    return wage_period
  end

  def default_tax_return
    tax_return = TaxReturn.new
    tax_return.accounting_period_id = self.id
    tax_return.name = 'Inkomstdeklaration ' + accounting_from.strftime('%Y')
    tax_return.deadline = accounting_to + 5.months
    return tax_return
  end

  def can_delete?
    return false if opening_balance
    return false if verificates.size > 0
    true
  end
end
