class TemplateItem < ActiveRecord::Base
  # t.string   :account_id
  # t.string   :description
  # t.boolean  :enable_debit
  # t.boolean  :enable_credit
  # t.integer  :organization_id
  # t.integer  :template_id
  # t.timestamps

  attr_accessible :account_id, :description, :enable_debit, :enable_credit

  belongs_to :organization
  belongs_to :account
  belongs_to :template

  validates :account_id, presence: true
  validates :description, presence: true

  def number
    account.number
  end

  def can_delete?
    true
  end
end
