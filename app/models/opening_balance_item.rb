class OpeningBalanceItem < ActiveRecord::Base
  # t.string   :account_id
  # t.string   :description
  # t.integer  :debit
  # t.integer  :credit
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :opening_balance_id
  # t.timestamps

  attr_accessible :account_id, :description, :debit, :credit

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :opening_balance
  belongs_to :account

  validates :account_id, presence: true
  validates :description, presence: true

  def account_number
    account.number
  end

  def posting_date
    opening_balance.posting_date_formatted
  end

  def can_delete?
    true
  end
end
