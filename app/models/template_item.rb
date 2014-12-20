class TemplateItem < ActiveRecord::Base
  # t.string   :account
  # t.string   :description
  # t.boolean  :enable_debit
  # t.boolean  :enable_credit
  # t.integer  :organization_id
  # t.integer  :template_id
  # t.timestamps

  attr_accessible :account, :description, :enable_debit, :enable_credit

  belongs_to :organization
  belongs_to :template

  validates :account, presence: true
  validates :description, presence: true

  def can_delete?
    true
  end
end
