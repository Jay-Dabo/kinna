module Services
  class InkCodeCreator
    require 'csv'
    def initialize(organization, user, accounting_plan)
      @user = user
      @organization = organization
      @accounting_plan = accounting_plan
    end

    def read_and_save
      first = true
      balance = true
      CSV.foreach('INK2_15_ver1.csv', { :col_sep => ';' }) do |row|
        if first
          first = false
        elsif !row[0].blank? && row[0].length == 4 && balance
          ink_code_id = add_ink_code(row[1], row[2], 'ub', row[3])

          len = row[3].length
          if row[3].include? 'exkl'
            ink_to_accounting_plan_exkl(ink_code_id, row[1], row[3])
          elsif len == 4
            ink_to_accounting_plan(ink_code_id, row[3])
          else
            ink_multiple(ink_code_id, row[3])
          end
          balance = false if row[1] == '2.50'
        elsif !row[0].blank? && row[0].length == 4 && !row[1].blank?
          ink_code_id = add_ink_code(row[1], row[2], 'accounting_period', row[3])

          len = row[3].length
          if row[3].include? 'exkl'
            ink_to_accounting_plan_exkl(ink_code_id, row[1], row[3])
          elsif row[3].start_with?('+')
            ink_plus(ink_code_id, row[3])
          elsif row[3].start_with?('-')
            ink_minus(ink_code_id, row[3])
          elsif len == 4
            ink_to_accounting_plan(ink_code_id, row[3])
          else
            ink_multiple(ink_code_id, row[3])
          end
        end
      end
    end

    def add_ink_code(code, text, sum_method, bas_accounts)
      ink_code = InkCode.new
      ink_code.code = code
      ink_code.text = text
      ink_code.sum_method = sum_method
      ink_code.bas_accounts = bas_accounts
      ink_code.organization = @organization
      ink_code.save
      return ink_code.id
    end

    def ink_multiple(id, bas_accounts)
      accounts = bas_accounts.split(', ')
      accounts.each { |account|
        ink_to_accounting_plan(id, account) if account.length == 4
        ink_to_accounting_plan_interval(id, account) if account.length == 9
      }
    end

    def ink_plus(id, bas_account)
      account = bas_account.gsub(/[+ ]/, '')
      ink_to_accounting_plan(id, account) if account.length == 4
      ink_to_accounting_plan_interval(id, account) if account.length == 9
    end

    def ink_minus(id, bas_account)
      account = bas_account.gsub(/-/, '')
      ink_to_accounting_plan(id, account) if account.length == 4
      ink_to_accounting_plan_interval(id, account) if account.length == 9
    end

    def ink_to_accounting_plan(id, account)
      from = set_from(account)
      to = set_tom(account)
      @accounting_plan.accounts.where('number >= ? AND number <= ?', from, to).update_all(ink_code_id: id )
    end

    def ink_to_accounting_plan_interval(id, account_interval)
      accounts = account_interval.split("-")
      from = set_from(accounts[0])
      to = set_tom(accounts[1])
      @accounting_plan.accounts.where('number >= ? AND number <= ?', from, to).update_all(ink_code_id: id )
    end

    def ink_to_accounting_plan_exkl(id, code, special)
      case code
      when '2.1'
        ink_to_accounting_plan_interval(id, '1000-1087')
        ink_to_accounting_plan_interval(id, '1089-1099')
      when '2.3'
        ink_to_accounting_plan_interval(id, '1100-1199')
        ink_to_accounting_plan_interval(id, '1130-1179')
        ink_to_accounting_plan_interval(id, '1190-1199')
      when '2.4'
        ink_to_accounting_plan_interval(id, '1200-1279')
        ink_to_accounting_plan_interval(id, '1290-1299')
      when '2.25'
        ink_to_accounting_plan_interval(id, '1800-1859')
        ink_to_accounting_plan_interval(id, '1870-1899')
      when '2.34'
        ink_to_accounting_plan_interval(id, '2220-2229')
        ink_to_accounting_plan_interval(id, '2240-2299')
      when '2.49'
        ink_to_accounting_plan_interval(id, '2490-2491')
        ink_to_accounting_plan_interval(id, '2493-2499')
        ink_to_accounting_plan_interval(id, '2600-2799')
        ink_to_accounting_plan_interval(id, '2800-2859')
        ink_to_accounting_plan_interval(id, '2880-2899')
      when '3.2'
        ink_to_accounting_plan_interval(id, '4900-4909')
        ink_to_accounting_plan_interval(id, '4932-4959')
        ink_to_accounting_plan_interval(id, '4970-4979')
        ink_to_accounting_plan_interval(id, '4990-4999')
      when '3.9'
        ink_to_accounting_plan_interval(id, '7700-7739')
        ink_to_accounting_plan_interval(id, '7750-7789')
        ink_to_accounting_plan_interval(id, '7800-7899')
      when '3.12'
        ink_to_accounting_plan_interval(id, '8000-8069')
        ink_to_accounting_plan_interval(id, '8090-8099')
      when '3.13'
        ink_to_accounting_plan_interval(id, '8100-8169')
        ink_to_accounting_plan_interval(id, '8190-8199')
      when '3.14'
        ink_to_accounting_plan_interval(id, '8200-8269')
        ink_to_accounting_plan_interval(id, '8290-8299')
      when '3.15'
        ink_to_accounting_plan_interval(id, '8300-8369')
        ink_to_accounting_plan_interval(id, '8390-8399')
      when '3.26'
        ink_to_accounting_plan_interval(id, '8900-8989')
      else
      end
    end

    def set_from(account)
      nbr = account.gsub(/[x]/, '')
      if nbr.length == 3
        nbr = nbr.to_i*10
      elsif nbr.length == 2
        nbr = nbr.to_i*100
      end
      return nbr
    end

    def set_tom(account)
      nbr = account.gsub(/[x]/, '')
      if nbr.length == 3
        nbr = nbr.to_i*10
        nbr += 9
      elsif nbr.length == 2
        nbr = nbr.to_i*100
        nbr += 99
      end
      return nbr
    end
  end
end
