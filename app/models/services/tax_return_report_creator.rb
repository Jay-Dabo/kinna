module Services
  class TaxReturnReportCreator

    def initialize(organization, user, tax_return)
      @user = user
      @organization = organization
      @tax_return = tax_return
    end

    def ink_code_part(ink_code)
      @accounting_period = AccountingPeriod.find(@tax_return.accounting_period_id)
      @accounts = Account.where('accounting_plan_id = ? AND ink_code_id = ?', @accounting_period.accounting_plan_id, ink_code.id).select(:id)
      case ink_code.sum_method
        when 'accounting_period'
          @ver_accounting_period = @organization.verificates.where("accounting_period_id = ? AND state = 'final' ", @tax_return.accounting_period_id).select(:id)
          ib = OpeningBalanceItem.where("accounting_period_id = ? AND account_id IN(?)", @accounting_period.id, @accounts)
          ver = VerificateItem.where("verificate_id IN(?) AND account_id IN(?)", @ver_accounting_period, @accounts)
          @items = ib + ver
        when 'ub'
          @items = ClosingBalanceItem.where("accounting_period_id = ? AND account_id IN(?)", @tax_return.accounting_period_id, @accounts)
          Rails.logger.info "->#{@items.size} #{@items.inspect}"
        else
      end
      return @items
    end

    def save_report
      @accounting_period = AccountingPeriod.find(@tax_return.accounting_period_id)
      @ver_accounting_period = @organization.verificates.where("accounting_period_id = ? AND state = 'final'", @tax_return.accounting_period_id).select(:id)
      @ink_codes = @organization.ink_codes
      total = 0
      @ink_codes.each do |ink_code|
        @accounts = Account.where('accounting_plan_id = ? AND ink_code_id = ?', @accounting_period.accounting_plan_id, ink_code.id).select(:id)
        Rails.logger.info "->->#{@accounts.size} #{ink_code.code}"
        case ink_code.sum_method
          when 'accounting_period'
            ib_sum = OpeningBalanceItem.where("accounting_period_id = ? AND account_id IN(?)", @accounting_period.id, @accounts).sum("debit-credit")
            ver_sum = VerificateItem.where("verificate_id IN(?) AND account_id IN(?)", @ver_accounting_period, @accounts).sum("debit-credit")
            amount = ib_sum + ver_sum
            total += amount
            save_tax_return_report(ink_code, -amount, @accounting_period, @tax_return)
          when 'ub'
            amount = ClosingBalanceItem.where("accounting_period_id = ? AND account_id IN(?)", @accounting_period.id, @accounts).sum("debit-credit")
            save_tax_return_report(ink_code, -amount, @accounting_period, @tax_return)
          when 'total'
            save_tax_return_report(ink_code, -total, @accounting_period, @tax_return)
          else
        end
      end
      @tax_return.state_change('mark_calculated', DateTime.now) if @tax_return.preliminary?
      return true
    end

    def delete_report
      @tax_return_reports = @organization.tax_return_reports.where("accounting_period_id = ? ", @tax_return.accounting_period_id)
      @tax_return_reports.each do |tax_return_report|
        tax_return_report.destroy
      end
    end

    def save_tax_return_report(ink_code, amount, accounting_period, tax_return)
      return if amount == 0
      tax_return_report = TaxReturnReport.new
      tax_return_report.amount = amount.round
      tax_return_report.ink_code = ink_code
      tax_return_report.organization = @organization
      tax_return_report.accounting_period = accounting_period
      tax_return_report.tax_return = tax_return
      tax_return_report.save
    end
  end
end
