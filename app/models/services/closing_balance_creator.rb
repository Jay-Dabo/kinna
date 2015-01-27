module Services
  class ClosingBalanceCreator

    def initialize(organization, user, closing_balance, accounting_period)
      @user = user
      @organization = organization
      @closing_balance = closing_balance
      @accounting_period = accounting_period
    end

    def add_from_ledger
      @organization.ledger_accounts.where('accounting_period_id = ?', @accounting_period.id)
      .each do |item|
        add_closing_balance_item(item.account_id, item.sum)
      end
    end

    def add_closing_balance_item(account, sum)
      @account = Account.find(account)
      return if @account.number > 2999
      closing_balance_item = @closing_balance.closing_balance_items.build
      closing_balance_item.organization = @organization
      closing_balance_item.accounting_period = @accounting_period
      closing_balance_item.account_id = account
      closing_balance_item.description = @account.description
      if sum > 0
        closing_balance_item.debit = sum
        closing_balance_item.credit = 0
      else
        closing_balance_item.debit = 0
        closing_balance_item.credit = -sum
      end
      closing_balance_item.save
    end
  end
end
