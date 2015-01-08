module Services
  class VerificateCreator

    def initialize(organization, user, object)
      @user = user
      @organization = organization
      @object = object
    end

    def save_vat_report
      @vat_period = @object
      @accounting_period = AccountingPeriod.find(@vat_period.accounting_period_id)
      @verificate = save_verificate('Momsredovisning', @accounting_period)

      @vat_period.vat_reports.each do |report|
        @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code_id = ?",
                                 @organization.id, @accounting_period.accounting_plan_id, report.tax_code.id).first

        if report.amount != 0 && (report.tax_code.code == 10 || report.tax_code.code == 11 || report.tax_code.code == 12)
          save_verificate_item(@verificate, @account, report.amount, 0, @accounting_period)
        elsif report.amount != 0 && report.tax_code.code == 48
          save_verificate_item(@verificate, @account, 0, -report.amount, @accounting_period)
        elsif report.tax_code.code == 49
          @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND number = ?",
                                   @organization.id, @accounting_period.accounting_plan_id, '1940').first
          save_verificate_item(@verificate, @account, 0, report.amount, @accounting_period)
        else
        end
      end
    end

    def save_verificate(description, accounting_period)
      @verificate = Verificate.new
      @verificate.posting_date = DateTime.now
      @verificate.description = description
      @verificate.organization = @organization
      @verificate.accounting_period = accounting_period
      @verificate.save
      return @verificate
    end

    def save_verificate_item(verificate, account, debit, credit, accounting_period)
      verificate_item = verificate.verificate_items.build
      verificate_item.account_id = account.id
      verificate_item.description = account.description
      verificate_item.debit = debit
      verificate_item.credit = credit
      verificate_item.organization = @organization
      verificate_item.accounting_period = accounting_period
      verificate_item.save
    end
  end
end
