class OpeningBalance < ActiveRecord::Base
  # t.string   :description
  # t.string   :state
  # t.datetime :posting_date
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.timestamps

  attr_accessible :posting_date, :description, :accounting_period_id

  belongs_to :organization
  belongs_to :accounting_period
  has_many   :opening_balance_items, dependent: :delete_all

  validates :accounting_period_id, presence: true, uniqueness: {scope: [:organization_id, :accounting_period_id]}
  validates :description, presence: true


  STATE_CHANGES = [:mark_final]

  def state_change(new_state, changed_at = nil)
    return false unless STATE_CHANGES.include?(new_state.to_sym)
    send(new_state, changed_at)
  end

  state_machine :state, initial: :preliminary do
    before_transition on: :mark_final, do: :set_posting_date
    after_transition on: :mark_final, do: :create_ledger_transactions

    event :mark_final do
      transition preliminary: :final
    end
  end

  def set_posting_date(transition)
    self.posting_date = transition.args[0]
  end

  def create_ledger_transactions
    opening_balance_items.each do |opening_balance_item|
      debit = opening_balance_item.debit || 0
      credit = opening_balance_item.credit || 0
      ledger_transaction = LedgerTransaction.new(
          parent: self,
          accounting_period: accounting_period,
          ledger: accounting_period.ledger,
          account: opening_balance_item.account,
          posting_date: posting_date,
          text: description,
          sum: debit - credit)
      ledger_transaction.organization_id = organization_id
      ledger_transaction.save
    end
  end

  def total_debit
    return 0 if opening_balance_items.count <= 0
    opening_balance_items.inject(0) { |i, item| (item.debit || 0) + i }
  end

  def total_credit
    return 0 if opening_balance_items.count <= 0
    opening_balance_items.inject(0) { |i, item| (item.credit || 0) + i }
  end

  def posting_date_formatted
    posting_date.strftime("%Y-%m-%d")
  end

  def can_delete?
    preliminary?
  end
end
