module Services
  class VatReportCreator

    def initialize(organization, user, vat_period)
      @user = user
      @organization = organization
      @vat_period = vat_period
    end

    def tax_code_part(tax_code)
      @accounting_period = AccountingPeriod.find(@vat_period.accounting_period_id)
      @accounts = Account.where('accounting_plan_id = ? AND tax_code_id = ?', @accounting_period.accounting_plan_id, tax_code.id).select(:id)
      case tax_code.sum_method
        when 'accounting_period'
          @ver_accounting_period = @organization.verificates.where("accounting_period_id = ? AND state = 'final' AND posting_date <= ?", @vat_period.accounting_period_id, @vat_period.vat_to).select(:id)
          ib = OpeningBalanceItem.where("accounting_period_id = ? AND account_id IN(?)", @accounting_period.id, @accounts)
          ver = VerificateItem.where("verificate_id IN(?) AND account_id IN(?)", @ver_accounting_period, @accounts)
          @items = ib + ver
        when 'vat_period'
          @ver_vat_period = @organization.verificates.where("accounting_period_id = ? AND state = 'final' AND posting_date >= ? AND posting_date <= ?", @vat_period.accounting_period_id, @vat_period.vat_from, @vat_period.vat_to).select(:id)
          @items = VerificateItem.where("verificate_id IN(?) AND account_id IN(?)", @ver_vat_period, @accounts)
        else
      end
      return @items
    end

    def save_report
      @accounting_period = AccountingPeriod.find(@vat_period.accounting_period_id)
      @ver_vat_period = @organization.verificates.where("accounting_period_id = ? AND state = 'final' AND posting_date >= ? AND posting_date <= ?", @vat_period.accounting_period_id, @vat_period.vat_from, @vat_period.vat_to).select(:id)
      @ver_accounting_period = @organization.verificates.where("accounting_period_id = ? AND state = 'final' AND posting_date <= ?", @vat_period.accounting_period_id, @vat_period.vat_to).select(:id)
      @tax_codes = @organization.tax_codes.where("code > 0 AND code <= 49")
      total = 0
      @tax_codes.each do |tax_code|
        @accounts = Account.where('accounting_plan_id = ? AND tax_code_id = ?', @accounting_period.accounting_plan_id, tax_code.id).select(:id)
        case tax_code.sum_method
          when 'accounting_period'
            ib_sum = OpeningBalanceItem.where("accounting_period_id = ? AND account_id IN(?)", @accounting_period.id, @accounts).sum("debit-credit")
            ver_sum = VerificateItem.where("verificate_id IN(?) AND account_id IN(?)", @ver_accounting_period, @accounts).sum("debit-credit")
            amount = ib_sum + ver_sum
            total += amount
            save_vat_report(tax_code, -amount, @accounting_period, @vat_period)
          when 'vat_period'
            amount = VerificateItem.where("verificate_id IN(?) AND account_id IN(?)", @ver_vat_period, @accounts).sum("debit-credit")
            save_vat_report(tax_code, -amount, @accounting_period, @vat_period)
          when 'total'
            save_vat_report(tax_code, -total, @accounting_period, @vat_period)
          else
        end
      end
      @vat_period.state_change('mark_calculated', DateTime.now)
    end

    def delete_vat_report
      @vat_reports = @organization.vat_reports.where("vat_period_id = ? ", @vat_period.id)
      @vat_reports.each do |vat_report|
        vat_report.destroy
      end
    end

    def save_vat_report(tax_code, amount, accounting_period, vat_period)
      vat_report = VatReport.new
      vat_report.amount = amount.round
      vat_report.tax_code = tax_code
      vat_report.organization = @organization
      vat_report.accounting_period = accounting_period
      vat_report.vat_period = vat_period
      vat_report.save
    end
  end
end
