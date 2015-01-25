class Ledger < ActiveRecord::Base
  # t.string   :name
  # t.integer  :organization_id
  # t.integer  :accounting_period_id

  attr_accessible :name, :accounting_period

  belongs_to :organization
  belongs_to :accounting_period
  has_many   :ledger_accounts
  has_many   :ledger_transactions

  validates :accounting_period, presence: true

  def can_delete?
    false
  end
end
