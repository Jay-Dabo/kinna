class Job::LedgerTransactionEvent
  @queue = :ledger_transaction_events

  def self.perform(ledger_transaction_id)
    Rails.logger.info "-->>LedgerTransactionEvent.perform(#{ledger_transaction_id})"
    trans = LedgerTransaction.find(ledger_transaction_id)
    sum_ledger(trans)
  end

  def self.sum_ledger(trans)
    Rails.logger.info "-->>LedgerTransactionEvent.sum_ledger(#{trans.inspect})"
    ledger_accounts = trans.ledger.ledger_accounts.where(account_id: trans.account_id)
    unless ledger_accounts.size > 0
      Rails.logger.info "-->>New LedgerAccount"
      ledger_account = LedgerAccount.new
      ledger_account.name = "MM"
      ledger_account.organization_id = trans.organization_id
      ledger_account.accounting_period_id = trans.accounting_period_id
      ledger_account.ledger_id = trans.ledger_id
      ledger_account.account_id = trans.account_id
      ledger_account.sum = trans.sum
      ledger_account.save
      Rails.logger.info "-->>New LedgerAccount finish"
    else
      Rails.logger.info "-->>Update LedgerAccount(#{ledger_accounts.inspect})"
      ledger_account = ledger_accounts.first
      ledger_account.sum += trans.sum
      ledger_account.save
    end
  end
end
