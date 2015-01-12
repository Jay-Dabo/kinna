class VerificateItem < ActiveRecord::Base
  # t.string   :account_id
  # t.string   :description
  # t.integer  :debit
  # t.integer  :credit
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :verificate_id
  # t.integer  :result_unit_id
  # t.integer  :project_id
  # t.timestamps

  attr_accessible :account_id, :description, :debit, :credit

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :verificate
  belongs_to :account
  belongs_to :result_unit

  validates :account_id, presence: true
  validates :description, presence: true

  def verificate_number
    verificate.number
  end

  def verificate_description
    verificate.description
  end

  def account_number
    account.number
  end

  def posting_date
    verificate.posting_date_formatted
  end

  def final?
    return true if verificate.final?
    false
  end

  def can_delete?
    return false if verificate.final?
    true
  end
end
