class TaxReturn < ActiveRecord::Base
  # t.string   :name
  # t.datetime :deadline
  # t.string   :state
  # t.datetime :calculated_at
  # t.datetime :reported_at
  # t.integer  :organization_id
  # t.integer  :accounting_period_id

  # t.timestamps


  attr_accessible :name, :deadline, :accounting_period_id

  belongs_to :organization
  belongs_to :accounting_period
  has_many :tax_return_reports

  validates :accounting_period, presence: true
  validates :name, presence: true, uniqueness: {scope: :organization_id}
  validates :deadline, presence: true

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
    # här skapas momsunderlager
    self.calculated_at = transition.args[0]
  end

  def report(transition)
    # här skapas verificate
    self.reported_at = transition.args[0]
  end

  def can_calculate?
    return false if state == 'reported'
    true
  end

  def can_report?
    ['calculated', 'reported'].include? state
  end

  def calculated?
    return false if state == 'preliminary'
    true
  end

  def can_delete?
    return false if tax_return_reports.size > 0
    true
  end
end
