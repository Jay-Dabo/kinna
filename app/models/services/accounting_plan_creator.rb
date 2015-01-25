module Services
  class AccountingPlanCreator
    require 'csv'
    def initialize(organization, user)
      @user = user
      @organization = organization
      @accounting_plan
      @accounting_class
      @accounting_group
    end

    def accounting_plan
      @accounting_plan
    end

    def BAS_read_and_save
      class_id = 'x'
      group_id = 'x'
      first = true
      CSV.foreach('Kontoplan_Normal_2014_ver1.csv', { :col_sep => ';' }) do |row|
        if first
          save_account_plan(row[1],'importerat')
          first = false
        elsif row[2].blank? && row[5] && row[5].length == 4
          save_account(row[5], row[6], class_id, group_id)
        elsif ((row[2] && row[2].strip.length == 1) || (row[2] && row[2].length == 3))
          class_id = save_account_class(row[2], row[3])
        elsif ((row[2] && row[2].length == 2) || (row[2] && row[2].length == 5))
          group_id = save_account_group(row[2], row[3])
        elsif row[2] && row[2].length == 4 && row[5].blank?
          save_account(row[2], row[3], class_id, group_id)
        elsif row[2] && row[2].length == 4 && row[5] && row[5].length == 4
          save_account(row[2], row[3], class_id, group_id)
          save_account(row[5], row[6], class_id, group_id)
        end

      end
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

    def K1_read_and_save
      class_id = 'x'
      group_id = 'x'
      first = true
      CSV.foreach('Kontoplan_K1_2014_ver1.csv', { :col_sep => ';' }) do |row|
        if first
          save_account_plan(row[1],'importerat')
          first = false
        elsif row[1] && (row[1].at(1) == ' ' || row[1].at(3) == ' ')
          i = row[1].index(' ')
          class_id = save_account_class(row[1][0,i], row[1][i..99])
        elsif row[1] && (row[1].at(2) == ' ' || row[1].at(5) == ' ')
          i = row[1].index(' ')
          group_id = save_account_group(row[1][0,i], row[1][i..99])
        elsif row[1] && row[1].length == 4 && row[4].nil?
          save_account(row[1], row[2], class_id, group_id)
        elsif row[1] && row[1].length == 4 && row[4] && row[4].length == 4
          save_account(row[1], row[2], class_id, group_id)
          save_account(row[4], row[5], class_id, group_id)
        elsif row[1].nil? && row[4] && row[4].length == 4
          save_account(row[4], row[5], class_id, group_id)
        end

      end
    end

    def K1_tax_code_update
      update_account_tax_code('3000', 05)
      update_account_tax_code('2610', 10)
      update_account_tax_code('2620', 11)
      update_account_tax_code('2630', 12)
      update_account_tax_code('2640', 48)

      update_account_tax_code('7000', 50)
      update_account_tax_code('2730', 78)
      update_account_tax_code('2710', 82)

      update_account_tax_code('1920', 101)
      update_account_tax_code('7500', 102)
    end

    def K1_mini_read_and_save
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
      return @accounting_class.id
    end

    def save_account_group(number, name)
      @accounting_group = @accounting_plan.accounting_groups.build
      @accounting_group.number = number
      @accounting_group.name = name
      @accounting_group.organization_id = @organization.id
      @accounting_group.accounting_plan_id = @accounting_plan.id
      @accounting_group.save
      return @accounting_group.id
    end

    def save_account(number, name, class_id, group_id)
      @account = @accounting_plan.accounts.build
      @account.number = number
      @account.description = name
      @account.organization_id = @organization.id
      @account.accounting_plan_id = @accounting_plan.id
      @account.accounting_class_id = class_id
      @account.accounting_group_id = group_id
      @account.save
    end

    def update_account_tax_code(account, tax_code)
      @account = @accounting_plan.accounts.find_by_number(account)
      @tax_code = @organization.tax_codes.find_by_code(tax_code)
      @account.tax_code = @tax_code
      @account.save
    end

    def update_account_ink_code(account, ink_code)
      @account = @accounting_plan.accounts.find_by_number(account)
      @ink_code = @organization.ink_codes.find_by_code(ink_code)
      @account.ink_code = @ink_code
      @account.save
    end
  end
end
