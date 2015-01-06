class VatPeriod < ActiveRecord::Base
  # t.string   :name
  # t.datetime :vat_from
  # t.datetime :vat_to
  # t.datetime :deadline
  # t.decimal  :box_05
  # t.decimal  :box_10
  # t.decimal  :box_11
  # t.decimal  :box_12
  # t.decimal  :box_48
  # t.decimal  :box_49
  # t.string   :state
  # t.datetime :calculated_at
  # t.datetime :reported_at
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :verificate_id

  # t.timestamps


  attr_accessible :name, :vat_from, :vat_to, :accounting_period_id, :deadline, :box_05, :box_10, :box_11, :box_12,
                  :box_48, :box_49

  belongs_to :organization
  belongs_to :accounting_period
  has_one :verificate

  validates :accounting_period, presence: true
  validates :name, presence: true, uniqueness: {scope: :organization_id}
  validates :vat_from, presence: true
  validates :vat_to, presence: true
  validate :check_to
  validate :overlaping_period
  validates :deadline, presence: true

  def check_to
    if vat_from >= vat_to
      errors.add(:vat_to, I18n.t(:period_error))
    end
  end

  def overlaping_period
    p = VatPeriod.where('organization_id = ? and vat_to >= ? and vat_from <= ?' , organization_id, vat_from, vat_to).count
    if new_record?
      errors.add(:vat_to, I18n.t(:within_period)) if p > 0
    else
      errors.add(:vat_to, I18n.t(:within_period)) if p > 1
    end
  end

  STATE_CHANGES = [:mark_calculated, :mark_reported]

  def state_change(event, changed_at = nil)
    return false unless STATE_CHANGES.include?(event.to_sym)
    send(event, changed_at)
  end

  state_machine :state, initial: :preliminary do
    before_transition on: :mark_calulated, do: :calculate
    before_transition on: :mark_reported, do: :report

    event :mark_calculated do
      transition preliminary: :calculated
    end
    event :mark_reported do
      transition calculated: :reported
    end
  end

  def calulate(transition)
    self.calculated_at = transition.args[0]
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

  def can_delete?
    true
  end
end
