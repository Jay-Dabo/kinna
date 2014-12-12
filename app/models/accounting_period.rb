class AccountingPeriod < ActiveRecord::Base
  # t.string   :name
  # t.datetime :accounting_from
  # t.datetime :accounting_to
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :name, :accounting_from, :accounting_to

  belongs_to :organization

  validates :name, presence: true, uniqueness: {scope: :organization_id}
  validates :accounting_from, presence: true
  validates :accounting_to, presence: true
  validate :check_to
  validate :overlaping_period

  def check_to
    if accounting_from >= accounting_to
      errors.add(:accounting_to, I18n.t(:period_error))
    end
  end

  def overlaping_period
    p = AccountingPeriod.where('organization_id = ? and accounting_to >= ? and accounting_from <= ?' , organization_id, accounting_from, accounting_to).count
    if new_record?
      errors.add(:accounting_to, I18n.t(:within_period)) if p > 0
    else
      errors.add(:accounting_to, I18n.t(:within_period)) if p > 1
    end
  end

  def can_delete?
    true
  end
end
