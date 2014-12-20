class OpeningBalanceItem < ActiveRecord::Base
  # t.string   :account
  # t.string   :description
  # t.integer  :debit
  # t.integer  :credit
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :opening_balance_id
  # t.timestamps

  attr_accessible :account, :description, :debit, :credit

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :opening_balance

  validates :account, presence: true
  validates :description, presence: true

  def can_delete?
    true
  end
end
