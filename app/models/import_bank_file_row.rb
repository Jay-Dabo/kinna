class ImportBankFileRow < ActiveRecord::Base
  # t.datetime :posting_date
  # t.decimal  :amount, precision: 9, scale: 2
  # t.string   :bank_account
  # t.string   :name
  # t.string   :reference
  # t.decimal  :bank_balance, precision: 11, scale: 2
  # t.string   :note
  # t.boolean   :posted
  # t.integer  :organization_id
  # t.integer  :import_bank_file_id
  # t.timestamps

  attr_accessible :posting_date, :amount, :bank_account, :name

  belongs_to :organization
  belongs_to :import_bank_file
  has_one    :verificate

  def set_posted
    self.posted = true
    self.save
  end

  def can_delete?
    true
  end
end
