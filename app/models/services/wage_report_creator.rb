module Services
  class WageReportCreator

    # t.integer  :amount
    # t.integer  :organization_id
    # t.integer  :accounting_period_id
    # t.integer  :wage_period_id
    # t.integer  :tax_code_id

    def initialize(organization, user, wage_period)
      @user = user
      @organization = organization
      @wage_period = wage_period
    end

    def tax_code_part(tax_code)
      @accounting_period = AccountingPeriod.find(@wage_period.accounting_period_id)
      @accounts = Account.where('accounting_plan_id = ? AND tax_code_id = ?', @accounting_period.accounting_plan_id, tax_code.id).select(:id)
      case tax_code.sum_method
        when 'accounting_period'
          @ver_accounting_period = @organization.verificates.where("accounting_period_id = ? AND state = 'final' AND posting_date <= ?", @wage_period.accounting_period_id, @wage_period.wage_to).select(:id)
          ib = OpeningBalanceItem.where("accounting_period_id = ? AND account_id IN(?)", @accounting_period.id, @accounts)
          ver = VerificateItem.where("verificate_id IN(?) AND account_id IN(?)", @ver_accounting_period, @accounts)
          @items = ib + ver
        when 'wage_period'
          @ver_wage_period = @organization.verificates.where("accounting_period_id = ? AND state = 'final' AND posting_date >= ? AND posting_date <= ?", @wage_period.accounting_period_id, @wage_period.wage_from, @wage_period.wage_to).select(:id)
          @items = VerificateItem.where("verificate_id IN(?) AND account_id IN(?)", @ver_wage_period, @accounts)
        else
      end
      return @items
    end

    def save_report
      @accounting_period = AccountingPeriod.find(@wage_period.accounting_period_id)
      @ver_wage_period = @organization.verificates.where("accounting_period_id = ? AND state = 'final' AND posting_date >= ? AND posting_date <= ?", @wage_period.accounting_period_id, @wage_period.wage_from, @wage_period.wage_to).select(:id)
      @ver_accounting_period = @organization.verificates.where("accounting_period_id = ? AND state = 'final' AND posting_date <= ?", @wage_period.accounting_period_id, @wage_period.wage_to).select(:id)
      @tax_codes = @organization.tax_codes.where("code > 49 AND code <= 99")
      total = 0
      @tax_codes.each do |tax_code|
        @accounts = Account.where('accounting_plan_id = ? AND tax_code_id = ?', @accounting_period.accounting_plan_id, tax_code.id).select(:id)
        case tax_code.sum_method
          when 'accounting_period'
            ib_sum = OpeningBalanceItem.where("accounting_period_id = ? AND account_id IN(?)", @accounting_period.id, @accounts).sum("debit-credit")
            ver_sum = VerificateItem.where("verificate_id IN(?) AND account_id IN(?)", @ver_accounting_period, @accounts).sum("debit-credit")
            amount = ib_sum + ver_sum
            total += amount
            save_wage_report(tax_code, -amount, @accounting_period, @wage_period)
          when 'wage_period'
            amount = VerificateItem.where("verificate_id IN(?) AND account_id IN(?)", @ver_wage_period, @accounts).sum("debit-credit")
            save_wage_report(tax_code, amount, @accounting_period, @wage_period)
          when 'total'
            save_wage_report(tax_code, -total, @accounting_period, @wage_period)
          else
        end
      end
      @wage_period.state_change('mark_tax_calculated', DateTime.now)
    end

    def delete_wage_report
      @wage_reports = @organization.wage_reports.where("wage_period_id = ? ", @wage_period.id)
      @wage_reports.each do |wage_report|
        wage_report.destroy
      end
    end

    def save_wage_report(tax_code, amount, accounting_period, wage_period)
      wage_report = WageReport.new
      wage_report.amount = amount.round
      wage_report.tax_code = tax_code
      wage_report.organization = @organization
      wage_report.accounting_period = accounting_period
      wage_report.wage_period = wage_period
      wage_report.save
    end
  end
end
