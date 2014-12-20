class OpeningBalance < ActiveRecord::Base
  # t.datetime :posting_date
  # t.string   :description
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.timestamps

  attr_accessible :posting_date, :description, :accounting_period_id

  belongs_to :organization
  belongs_to :accounting_period
  has_many   :opening_balance_items

  validates :accounting_period_id, presence: true
  validates :posting_date, presence: true
  validates :description, presence: true

  def total_debit
    return 0 if opening_balance_items.count <= 0
    opening_balance_items.inject(0) { |i, item| (item.debit || 0) + i }
  end

  def total_credit
    return 0 if opening_balance_items.count <= 0
    opening_balance_items.inject(0) { |i, item| (item.credit || 0) + i }
  end

  def can_delete?
    true
  end
end
