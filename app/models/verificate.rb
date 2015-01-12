class Verificate < ActiveRecord::Base
  # t.integer  :number
  # t.string   :state
  # t.datetime :posting_date
  # t.string   :description
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :template_id
  # t.integer  :vat_period_id
  # t.integer  :wage_period_id
  # t.timestamps

  attr_accessible :posting_date, :description, :accounting_period_id, :template_id

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :template
  belongs_to :vat_period
  belongs_to :wage_period
  has_many   :verificate_items, dependent: :delete_all

  validates :accounting_period_id, presence: true
  validates :posting_date, presence: true
  validates :description, presence: true
  validate :check_date

  def check_date
    if posting_date < accounting_period.accounting_from
      errors.add(:posting_date, I18n.t(:within_period))
    end
  end

  STATE_CHANGES = [:mark_final]

  def state_change(new_state, changed_at = nil)
    return false unless STATE_CHANGES.include?(new_state.to_sym)
    send(new_state, changed_at)
  end

  state_machine :state, initial: :preliminary do
    before_transition on: :mark_final, do: :generate_verificate_number
    after_transition on: :mark_final, do: :set_dependent

    event :mark_final do
      transition preliminary: :final
    end
  end

  def generate_verificate_number
    return false if !self.balanced?
    return false if self.posting_date <  accounting_period.allow_from
    return false if self.posting_date >  accounting_period.allow_to
    self.number = (Verificate.where(organization_id: self.organization_id, accounting_period_id: self.accounting_period_id).maximum(:number) || 0) +1
  end

  def set_dependent
    self.vat_period.state_change('mark_closed', DateTime.now) if self.vat_period
  end

  def total_debit
    return 0 if verificate_items.count <= 0
    verificate_items.inject(0) { |i, item| (item.debit || 0) + i }
  end

  def total_credit
    return 0 if verificate_items.count <= 0
    verificate_items.inject(0) { |i, item| (item.credit || 0) + i }
  end

  def balanced?
    return false if total_debit == 0
    return false if total_debit != total_credit
    true
  end

  def verificate_items?
    return true if verificate_items.count > 0
    false
  end
  def posting_date_formatted
    return o if !final?
    posting_date.strftime("%Y-%m-%d")
  end

  def preliminary?
    return true if state == 'preliminary'
    false
  end

  def final?
    return true if state == 'final'
    false
  end

  def can_delete?
    return false if final?
    true
  end
end
