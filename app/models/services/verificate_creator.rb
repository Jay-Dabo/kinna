module Services
  class VerificateCreator

    def initialize(organization, user, object)
      @user = user
      @organization = organization
      @object = object
      @verificate
    end

    def verificate_id
      @verificate.id
    end

    def save_vat_report
      @vat_period = @object
      @accounting_period = AccountingPeriod.find(@vat_period.accounting_period_id)
      @verificate = save_verificate(@vat_period.deadline, 'Momsredovisning','','',@accounting_period)
      @verificate.vat_period = @vat_period
      @verificate.save

      @vat_period.vat_reports.each do |report|
        @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code_id = ?",
                                 @organization.id, @accounting_period.accounting_plan_id, report.tax_code.id).first
        if report.amount != 0 && (report.tax_code.code == 10 || report.tax_code.code == 11 || report.tax_code.code == 12)
          save_verificate_item(@verificate, @account, report.amount, 0, @accounting_period)
        elsif report.amount != 0 && report.tax_code.code == 48
          save_verificate_item(@verificate, @account, 0, -report.amount, @accounting_period)
        elsif report.tax_code.code == 49
          @tax_code = @organization.tax_codes.find_by_code(101)
          @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code_id = ?",
                                   @organization.id, @accounting_period.accounting_plan_id, @tax_code.id).first
          save_verificate_item(@verificate, @account, 0, report.amount, @accounting_period)
        else
        end
      end
      @vat_period.state_change('mark_reported', DateTime.now)
    end

    def save_wage
      @wage_period = @object
      @accounting_period = AccountingPeriod.find(@wage_period.accounting_period_id)
      @verificate = save_verificate(@wage_period.payment_date, 'Löneutbetalning','','',@accounting_period)
      @verificate.wage_period_wage = @wage_period
      @verificate.save
      # OBS! utbetalning separat för varje anställd till konto??
      sum_salary = 0
      sum_tax = 0
      sum_payroll_tax = 0
      sum_amount = 0
      @wage_period.wages.each do |report|
        sum_salary += report.salary
        sum_tax += report.tax
        sum_payroll_tax += report.payroll_tax
        sum_amount += report.amount
      end

      @tax_code = @organization.tax_codes.find_by_code(50)
      @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code_id = ?",
                               @organization.id, @accounting_period.accounting_plan_id, @tax_code.id).first
      save_verificate_item(@verificate, @account, sum_salary, 0, @accounting_period)

      @tax_code = @organization.tax_codes.find_by_code(82)
      @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code_id = ?",
                               @organization.id, @accounting_period.accounting_plan_id, @tax_code.id).first
      save_verificate_item(@verificate, @account, 0, sum_tax, @accounting_period)

      @tax_code = @organization.tax_codes.find_by_code(102)
      @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code_id = ?",
                               @organization.id, @accounting_period.accounting_plan_id, @tax_code.id).first
      save_verificate_item(@verificate, @account, sum_payroll_tax, 0, @accounting_period)

      @tax_code = @organization.tax_codes.find_by_code(78)
      @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code_id = ?",
                               @organization.id, @accounting_period.accounting_plan_id, @tax_code.id).first
      save_verificate_item(@verificate, @account, 0, sum_payroll_tax, @accounting_period)

      @tax_code = @organization.tax_codes.find_by_code(101)
      @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code_id = ?",
                               @organization.id, @accounting_period.accounting_plan_id, @tax_code.id).first
      save_verificate_item(@verificate, @account, 0, sum_amount, @accounting_period)
      @wage_period.state_change('mark_wage_reported', DateTime.now)
    end

    def save_wage_report
      @wage_period = @object
      @accounting_period = AccountingPeriod.find(@wage_period.accounting_period_id)
      @verificate = save_verificate(@wage_period.deadline, 'Skatteredovisning','','', @accounting_period)
      @verificate.wage_period_report = @wage_period
      @verificate.save

      @wage_period.wage_reports.each do |report|
        @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code_id = ?",
                                 @organization.id, @accounting_period.accounting_plan_id, report.tax_code.id).first
        if report.amount != 0 && (report.tax_code.code == 78 || report.tax_code.code == 82)
          save_verificate_item(@verificate, @account, report.amount, 0, @accounting_period)
        elsif report.tax_code.code == 99
          @tax_code = @organization.tax_codes.find_by_code(101)
          @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code_id = ?",
                                   @organization.id, @accounting_period.accounting_plan_id, @tax_code.id).first
          save_verificate_item(@verificate, @account, 0, report.amount, @accounting_period)
        else
        end
      end
      @wage_period.state_change('mark_tax_reported', DateTime.now)
    end

    def save_bank_file_row
      @import_bank_file_row = @object
      @accounting_period = @organization.accounting_periods.where('accounting_from <= ? AND accounting_to >= ?', @import_bank_file_row.posting_date, @import_bank_file_row.posting_date).first
      Rails.logger.info "->#{@accounting_period.inspect}"
      @verificate = save_verificate( @import_bank_file_row.posting_date, @import_bank_file_row.name, @import_bank_file_row.reference, @import_bank_file_row.note, @accounting_period)
      @verificate.import_bank_file_row = @import_bank_file_row
      @verificate.save

      if @import_bank_file_row.amount > 0
        debit = @import_bank_file_row.amount
        credit = 0
      else
        debit = 0
        credit = -@import_bank_file_row.amount
      end
      @tax_code = @organization.tax_codes.find_by_code(101)
      @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code_id = ?",
                               @organization.id, @accounting_period.accounting_plan_id, @tax_code.id).first
      save_verificate_item(@verificate, @account, debit, credit, @accounting_period)
      @import_bank_file_row.verificate_id = @verificate.id
      @import_bank_file_row.save
    end

    def save_verificate(posting_date, description, reference, note, accounting_period)
      @verificate = Verificate.new
      @verificate.posting_date = posting_date
      @verificate.description = description
      @verificate.reference = reference
      @verificate.note = note
      @verificate.organization = @organization
      @verificate.accounting_period = accounting_period
      @verificate.save
      return @verificate
    end

    def save_verificate_item(verificate, account, debit, credit, accounting_period)
      verificate_item = verificate.verificate_items.build
      verificate_item.account_id = account.id
      verificate_item.description = account.description
      if debit < 0 || credit < 0
        verificate_item.debit = -credit
        verificate_item.credit = -debit
      else
        verificate_item.debit = debit
        verificate_item.credit = credit
      end

      verificate_item.organization = @organization
      verificate_item.accounting_period = accounting_period
      verificate_item.save
    end
  end
end
