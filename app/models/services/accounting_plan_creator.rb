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
      @account.name = name
      @account.organization_id = @organization.id
      @account.accounting_plan_id = @accounting_plan.id
      @account.accounting_class_id = class_id
      @account.accounting_group_id = group_id
      @account.save
    end
  end
end
