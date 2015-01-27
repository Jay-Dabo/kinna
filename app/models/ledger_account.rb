class LedgerAccount < ActiveRecord::Base
  # t.string   :name
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :ledger_id
  # t.integer  :account_id
  # t.decimal  :sum

  attr_accessible :name, :accounting_period_id, :ledger_id, :account_id, :sum

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :ledger
  belongs_to :account
  has_many   :ledger_transactions

  validates :accounting_period, presence: true
  validates :ledger, presence: true
  validates :account, presence: true

  delegate :number, to: :account

  def account_number
    account.number
  end
  def account_text
    account.description
  end
  def can_delete?
    false
  end
end
