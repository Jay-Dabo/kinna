class VerificateItem < ActiveRecord::Base
  # t.string   :account
  # t.string   :description
  # t.integer  :debit
  # t.integer  :credit
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :verificate_id
  # t.integer  :result_unit_id
  # t.integer  :project_id
  # t.timestamps

  attr_accessible :account, :description, :debit, :credit

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :verificate

  validates :account, presence: true
  validates :description, presence: true

  def can_delete?
    return false if verificate.final?
    true
  end
end
