class Wage < ActiveRecord::Base
  # t.datetime :wage_from
  # t.datetime :wage_to
  # t.datetime :payment_date
  # t.decimal  :salery
  # t.decimal  :addition
  # t.decimal  :discount
  # t.decimal  :tax
  # t.decimal  :namount
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :wage_period_id
  # t.integer  :employee_id

  attr_accessible :wage_from, :wage_to, :payment_date

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :wage_period
  belongs_to :employee
  has_one :verificate

  validates :accounting_period, presence: true
  validates :wage_from, presence: true
  validates :wage_to, presence: true
  validates :payment_date, presence: true

  def can_delete?
    true
  end
end
