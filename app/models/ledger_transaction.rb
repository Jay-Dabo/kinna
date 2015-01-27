class LedgerTransaction < ActiveRecord::Base
  # t.string   :parent_type
  # t.integer  :parent_id
  # t.integer  :organization_id
  # t.integer  :accounting_period_id
  # t.integer  :ledger_id
  # t.integer  :account_id
  # t.datetime :posting_date
  # t.interger :number
  # t.string   :text
  # t.decimal  :sum

  attr_accessible :name, :parent, :accounting_period, :ledger, :account, :posting_date, :number, :text, :sum

  belongs_to :organization
  belongs_to :accounting_period
  belongs_to :ledger
  belongs_to :account
  belongs_to :parent, polymorphic: true

  validates :accounting_period, presence: true
  validates :ledger, presence: true
  validates :account, presence: true

  after_commit :enqueue_event

  # Callback: after_commit
  def enqueue_event
    Rails.logger.info "->#{self.inspect}"
    Resque.enqueue(Job::LedgerTransactionEvent, id)
  end
end
