class WagePeriod < ActiveRecord::Base
  # t.string   :name
  # t.datetime :wage_from
  # t.datetime :wage_to
  # t.datetime :deadline
  # t.string   :state
  # t.datetime :wage_calculated_at
  # t.datetime :wage_reported_at
  # t.datetime :wage_closed_at
  # t.datetime :tax_calculated_at
  # t.datetime :tax_reported_at
  # t.integer  :tax_closed_at
  # t.integer  :organization_id
  # t.integer  :accounting_period_id

  # t.timestamps


  attr_accessible :name, :wage_from, :wage_to, :payment_date, :deadline, :accounting_period_id

  belongs_to :organization
  belongs_to :accounting_period
  has_many :wages
  has_many :wage_reports
  has_many :verificates

  validates :accounting_period, presence: true
  validates :name, presence: true, uniqueness: {scope: :organization_id}
  validates :wage_from, presence: true
  validates :wage_to, presence: true
  validate :check_to
  validate :overlaping_period
  validates :payment_date, presence: true
  validates :deadline, presence: true

  def check_to
    if wage_from >= wage_to
      errors.add(:wage_to, I18n.t(:period_error))
    end
  end

  def overlaping_period
    p = WagePeriod.where('organization_id = ? and wage_to >= ? and wage_from <= ?' , organization_id, wage_from, wage_to).count
    if new_record?
      errors.add(:wage_to, I18n.t(:within_period)) if p > 0
    else
      errors.add(:wage_to, I18n.t(:within_period)) if p > 1
    end
  end

  STATE_CHANGES = [:mark_wage_calculated, :mark_wage_reported, :mark_wage_closed,
                   :mark_tax_calculated, :mark_tax_reported, :mark_tax_closed]

  def state_change(event, changed_at = nil)
    return false unless STATE_CHANGES.include?(event.to_sym)
    send(event, changed_at)
  end

  state_machine :state, initial: :preliminary do
    before_transition on: :mark_wage_calculated, do: :wage_calculate
    before_transition on: :mark_wage_reported, do: :wage_report
    before_transition on: :mark_wage_closed, do: :wage_close
    before_transition on: :mark_tax_calculated, do: :tax_calculate
    before_transition on: :mark_tax_reported, do: :tax_report
    before_transition on: :mark_tax_closed, do: :tax_close

    event :mark_wage_calculated do
      transition preliminary: :wage_calculated
    end
    event :mark_wage_reported do
      transition wage_calculated: :wage_reported
    end
    event :mark_wage_closed do
      transition wage_reported: :wage_closed
    end
    event :mark_tax_calculated do
      transition wage_closed: :tax_calculated
    end
    event :mark_tax_reported do
      transition tax_calculated: :tax_reported
    end
    event :mark_tax_closed do
      transition tax_reported: :tax_closed
    end
  end

  def wage_calculate(transition)
    self.wage_calculated_at = transition.args[0]
  end

  def wage_report(transition)
    self.wage_reported_at = transition.args[0]
  end

  def wage_close(transition)
    self.wage_closed_at = transition.args[0]
  end

  def tax_calculate(transition)
    self.tax_calculated_at = transition.args[0]
  end

  def tax_report(transition)
    self.tax_reported_at = transition.args[0]
  end

  def tax_close(transition)
    self.tax_closed_at = transition.args[0]
  end

  def can_calculate_wage?
    ['preliminary', 'wage_calculated'].include? state
  end

  def can_calculate_tax?
    ['wage_closed', 'tax_calculated'].include? state
  end

  def can_report_wage?
    ['wage_calculated', 'wage_reported'].include? state
  end

  def can_report_tax?
    ['tax_calculated', 'tax_reported'].include? state
  end

  def show_wage?
    return false if state == 'preliminary'
    true
  end

  def show_tax?
    ['tax_calculated', 'tax_reported', 'tax_closed'].include? state
  end

  def can_delete?
    return false if wages.size > 0
    return false if wage_reports.size > 0
    true
  end
end
