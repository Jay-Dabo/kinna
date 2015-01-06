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
      if (@vat_period.box_10 != 0)
        @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code = 10", @organization.id, @accounting_period.accounting_plan_id).first
        save_verificate_item(@verificate, @account, -@vat_period.box_10, 0, @accounting_period)
      end
      if (@vat_period.box_11 != 0)
        @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code = 11", @organization.id, @accounting_period.accounting_plan_id).first
        save_verificate_item(@verificate, @account, -@vat_period.box_11, 0, @accounting_period)
      end
      if (@vat_period.box_12 != 0)
        @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code = 12", @organization.id, @accounting_period.accounting_plan_id).first
        save_verificate_item(@verificate, @account, -@vat_period.box_12, 0, @accounting_period)
      end
      if (@vat_period.box_49 != 0)
        @account = Account.where("organization_id = ? AND accounting_plan_id = ? AND tax_code = 49", @organization.id, @accounting_period.accounting_plan_id).first
        save_verificate_item(@verificate, @account, 0, @vat_period.box_49, @accounting_period)
      end
      if @verificate.balanced?
        @verificate.state_change('mark_final')
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
