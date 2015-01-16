module Services
  class TemplateCreator

    def initialize(organization, user, accounting_plan)
      @user = user
      @organization = organization
      @accounting_plan = accounting_plan
    end

    def save_templates
      template = save_template( "Inköp kontant",  "Inköp kontant direktavskrivning")
      save_template_item(template, '4000','Varor', true, false)
      save_template_item(template, '2640','Ingående moms', true, false)
      save_template_item(template, '1920','PlusGiro', false, true)

      template = save_template( "Försäljning faktura",  "Försäljning 25% moms")
      save_template_item(template, '3000','Försäljning och utfört arbete samt övriga momspliktiga intäkter', false, true)
      save_template_item(template, '2610','Utgående moms', false, true)
      save_template_item(template, '1500','Kundfordringar', true, false)

      template = save_template( "Kundbetalning",  "Betalning kundfaktura 25% moms")
      save_template_item(template, '1500','Kundfordringar', false, true)
      save_template_item(template, '1920','PlusGiro', true, false)
    end

    def save_template(name, description)
      template = Template.new
      template.name = name
      template.description = description
      template.accounting_plan= @accounting_plan
      template.organization = @organization
      template.save
      return template
    end
    def save_template_item(template, account_number, description, enable_debit, enable_credit)
      account = @accounting_plan.accounts.where('number = ?', account_number).first
      template_item = template.template_items.build
      template_item.account = account
      template_item.description = description
      template_item.enable_debit = enable_debit
      template_item.enable_credit = enable_credit
      template_item.organization = @organization
      template_item.save
    end
  end
end
