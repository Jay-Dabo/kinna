module Services
  class TemplateCreator

    def initialize(organization, user, accounting_plan)
      @user = user
      @organization = organization
      @accounting_plan = accounting_plan
    end

    def save_templates_bas
      template = save_template( "Inköp kontant",  "Inköp kontant direktavskrivning")
      save_template_item(template, '4000','Inköp av varor från Sverige', true, false)
      save_template_item(template, '2640','Ingående moms', true, false)
      save_template_item(template, '1920','PlusGiro', false, true)

      template = save_template( "Försäljning faktura 25% moms",  "Försäljning 25% moms")
      save_template_item(template, '3001','Försäljning inom Sverige, 25 % moms', false, true)
      save_template_item(template, '2610','Utgående moms, 25 %', false, true)
      save_template_item(template, '3740','Öres- och kronutjämning', true, true)
      save_template_item(template, '1510','Kundfordringar', true, false)

      template = save_template( "Försäljning faktura 12% moms",  "Försäljning 12% moms")
      save_template_item(template, '3002','Försäljning inom Sverige, 12 % moms', false, true)
      save_template_item(template, '2620','Utgående moms, 12 %', false, true)
      save_template_item(template, '3740','Öres- och kronutjämning', true, true)
      save_template_item(template, '1510','Kundfordringar', true, false)

      template = save_template( "Försäljning faktura 6% moms",  "Försäljning 6% moms")
      save_template_item(template, '3003','Försäljning inom Sverige, 6 % moms', false, true)
      save_template_item(template, '2630','Utgående moms, 6 %', false, true)
      save_template_item(template, '3740','Öres- och kronutjämning', true, true)
      save_template_item(template, '1510','Kundfordringar', true, false)

      template = save_template( "Kundbetalning",  "Betalning kundfaktura")
      save_template_item(template, '1510','Kundfordringar', false, true)
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
