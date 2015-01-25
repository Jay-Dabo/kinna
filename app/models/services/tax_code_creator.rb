module Services
  class TaxCodeCreator

    def initialize(organization, user, accounting_plan)
      @user = user
      @organization = organization
      @accounting_plan = accounting_plan
    end

    def tax_codes_save
      add_tax_code(05, "Momspliktig försäljning", 'vat_period', 'vat')
      add_tax_code(10, "Utgående moms på försäljning 25 %", 'accounting_period', 'vat')
      add_tax_code(11, "Utgående moms på försäljning 12 %", 'accounting_period', 'vat')
      add_tax_code(12, "Utgående moms på försäljning 6 %", 'accounting_period', 'vat')
      add_tax_code(48, "Ingående moms", 'accounting_period', 'vat')
      add_tax_code(49, "Moms att betala eller få tillbaka", 'total', 'vat')

      add_tax_code(50, "Avgiftspliktig bruttolön utan förmåner", 'wage_period', 'wage')
      add_tax_code(55, "Underlag full arbetsgivaravgift 26 - 65 år", 'subset_55', 'wage')
      add_tax_code(57, "Underlag arbetsgivaravgift - 26 år", 'subset_57', 'wage')
      add_tax_code(59, "Underlag arbetsgivaravgift 65 år - ", 'subset_59', 'wage')
      add_tax_code(56, "Full arbetsgivaravgift 26 - 65 år", 'subset_56', 'wage')
      add_tax_code(58, "Arbetsgivaravgift - 26 år", 'subset_58', 'wage')
      add_tax_code(60, "Arbetsgivaravgift 65 år - ", 'subset_60', 'wage')
      add_tax_code(78, "Summa arbetsgivaravgifter", 'accounting_period', 'wage')
      add_tax_code(81, "Lön och förmåner inkl SINK", 'include_81', 'wage')
      add_tax_code(82, "Avdragen skatt från lön och förmåner", 'accounting_period', 'wage')
      add_tax_code(99, "Summa avgift och skatt att betala", 'total', 'wage') 

      add_tax_code(101, "Betalningskonto", 'none', 'default')
      add_tax_code(102, "Motkonto sociala avgifter", 'none', 'default')
    end

    def BAS_tax_code_update
      update_account_tax_code('3001', 05)
      update_account_tax_code('2610', 10)
      update_account_tax_code('2620', 11)
      update_account_tax_code('2630', 12)
      update_account_tax_code('2640', 48)

      update_account_tax_code('7210', 50)
      update_account_tax_code('2730', 78)
      update_account_tax_code('2710', 82)

      update_account_tax_code('1920', 101)
      update_account_tax_code('7500', 102)
    end

    def add_tax_code(code, text, sum_method, code_type)
      tax_code = TaxCode.new
      tax_code.code = code
      tax_code.text = text
      tax_code.sum_method = sum_method
      tax_code.code_type = code_type
      tax_code.organization = @organization
      tax_code.save
    end

    def update_account_tax_code(account, tax_code)
      @account = @accounting_plan.accounts.find_by_number(account)
      @tax_code = @organization.tax_codes.find_by_code(tax_code)
      @account.tax_code = @tax_code
      @account.save
    end
  end
end
