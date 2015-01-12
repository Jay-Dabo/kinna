class WagePeriod < ActiveRecord::Base
  # t.string   :name
  # t.datetime :wage_from
  # t.datetime :wage_to
  # t.datetime :deadline
  # t.decimal  :box_05
  # t.decimal  :box_10
  # t.decimal  :box_11
  # t.decimal  :box_12
  # t.decimal  :box_48
  # t.decimal  :box_49
  # t.string   :state
  # t.datetime :calculated_at
  # t.datetime :confirmed_at
  # t.datetime :reported_at
  # t.integer  :organization_id
  # t.integer  :accounting_period_id

  # t.timestamps


  attr_accessible :name, :wage_from, :wage_to, :payment_date, :deadline, :accounting_period_id, :box_05, :box_10, :box_11, :box_12,
                  :box_48, :box_49

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

  STATE_CHANGES = [:mark_calculated, :mark_confirmed, :mark_reported]

  def state_change(event, changed_at = nil)
    return false unless STATE_CHANGES.include?(event.to_sym)
    send(event, changed_at)
  end

  state_machine :state, initial: :preliminary do
    before_transition on: :mark_calulated, do: :calculate
    before_transition on: :mark_confirmed, do: :confirm
    before_transition on: :mark_reported, do: :report

    event :mark_calculated do
      transition preliminary: :calculated
    end
    event :mark_confirmed do
      transition calculated: :confirmed
    end
    event :mark_reported do
      transition confirmed: :reported
    end
  end

  def calulate(transition)
    self.calculated_at = transition.args[0]
  end

  def confirm(transition)
    # self.confirmed_at = transition.args[0]
  end

  def report(transition)
    self.reported_at = transition.args[0]
  end

  def can_calculate?
    return false if state == 'reported'
    true
  end

  def calculated?
    return false if state == 'preliminary'
    true
  end

  def can_report?
    return true
  end
  def can_delete?
    true
  end
end
