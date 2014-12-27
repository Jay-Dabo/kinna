module Services
  class ClosingBalanceCreator

    def initialize(organization, user, closing_balance, accounting_period)
      @user = user
      @organization = organization
      @closing_balance = closing_balance
      @accounting_period = accounting_period
    end

    def sum_verificates_and_save
      VerificateItem
        .joins(:verificate)
        .where("verificate_items.organization_id = ? AND verificate_items.accounting_period_id = ? AND verificates.state = 'final'", @organization.id, @accounting_period.id)
        .select('account_id as num','verificate_items.description as dsc', "SUM(debit) AS deb", "SUM(credit) AS cre")
        .group('account_id', 'verificate_items.description')
        .order('account_id')
        .each do |item|
          add_closing_balance_item(item.num, item.dsc, item.deb, item.cre)
      end
      OpeningBalanceItem
        .where('organization_id = ? AND accounting_period_id = ?', @organization.id, @accounting_period.id)
        .each do |item|
        update_closing_balance_item(item.account_id, item.description, item.debit, item.credit)
      end
    end

    def add_closing_balance_item(account, description, debit, credit)
      closing_balance_item = @closing_balance.closing_balance_items.build
      closing_balance_item.organization = @organization
      closing_balance_item.accounting_period = @accounting_period
      closing_balance_item.account_id = account
      closing_balance_item.description = description
      closing_balance_item.debit = debit
      closing_balance_item.credit = credit
      closing_balance_item.save
    end

    def update_closing_balance_item(account, description, debit, credit)
      closing_balance_item = @closing_balance.closing_balance_items.where('account_id = ?', account).first
      if closing_balance_item
        closing_balance_item.debit += debit if !debit.nil?
        closing_balance_item.credit += credit if !credit.nil?
        closing_balance_item.save
      else
        closing_balance_item = @closing_balance.closing_balance_items.build
        closing_balance_item.organization = @organization
        closing_balance_item.accounting_period = @accounting_period
        closing_balance_item.account_id = account
        closing_balance_item.description = description
        closing_balance_item.debit = debit
        closing_balance_item.credit = credit
        closing_balance_item.save
      end
    end
  end
end
