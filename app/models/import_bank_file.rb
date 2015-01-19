class ImportBankFile < ActiveRecord::Base
  # t.datetime :import_date
  # t.datetime :from_date
  # t.datetime :to_date
  # t.string   :reference
  # t.integer  :organization_id
  # t.timestamps

  attr_accessible :import_date, :from_date, :to_date, :reference

  belongs_to :organization
  has_many   :import_bank_file_rows, dependent: :destroy

  def can_delete?
    true
  end
end
