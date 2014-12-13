module Services
  class AccountingPlanCreator
    require 'csv'
    def initialize(organization, user)
      @user = user
      @organization = organization
      @accounting_plan
    end

    def read_and_save_file
      first = true
      CSV.foreach('Kontoplan_K1_Mini_2014_ver1.csv', { :col_sep => ';' }) do |row|
        if first
          save_account_plan(row[1],'importerat')
          first = false
        end
        if row[1] && (row[1].length == 2 || row[1].length == 3)
          save_account_class(row[1], row[2])
          if row[3].length == 4
            save_account(row[3], row[2])
          elsif row[3].length == 9
            k = row[3].split('-')
            save_account(k[0], row[2])
            save_account(k[1], row[2])
          elsif row[3].length == 10
            k = row[3].split(', ')
            save_account(k[0], row[2])
            save_account(k[1], row[2])
          else
            k = row[3].split(', ')
            save_account(k[0], row[2])
            save_account(k[1], row[2])
            save_account(k[2], row[2])
          end
        end
      end
    end

    def save_account_plan(name, description)
      @accounting_plan = AccountingPlan.new
      @accounting_plan.name = name
      @accounting_plan.description = description
      @accounting_plan.organization_id = @organization.id
      @accounting_plan.save
    end

    def save_account_class(number, name)
      @accounting_class = @accounting_plan.accounting_classes.build
      @accounting_class.number = number
      @accounting_class.name = name
      @accounting_class.organization_id = @organization.id
      @accounting_class.accounting_plan_id = @accounting_plan.id
      @accounting_class.save
    end

    def save_account(number, name)
      @account = @accounting_plan.accounts.build
      @account.number = number
      @account.name = name
      @account.organization_id = @organization.id
      @account.accounting_plan_id = @accounting_plan.id
      @account.save
    end
  end
end
