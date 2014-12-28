module Services
  class ImportSie
    def initialize(organization, user, accounting_period, accounting_plan, opening_balance)
      @user = user
      @organization = organization
      @accounting_plan = accounting_plan
      @accounting_period = accounting_period
      @opening_balance = opening_balance
      @sietyp = ''
    end

    def read_and_save
      sietyp = ''
      IO.foreach('EXPORT.SE') do |line|
        case @sietyp
          when '4'
            set_ib(line) if line.starts_with?('#IB')
          else
        end
        set_type(line) if line.starts_with?('#SIETYP')
      end
    end

    def set_type(line)
      @sietyp = line.from(7).strip
      Rails.logger.info ":#{@sietyp}:"
    end

    def set_ib(line)
      #type, period, account, amount
      field = line.split(' ')
      save_opening_balance_item(field[2], field[3].to_i)
    end

    def save_opening_balance_item(number, amount)
      #OBS konton som inte finns
      @account = @accounting_plan.accounts.where('number = ?', number).first
      if amount > 0
        debit = amount
        credit = 0
      else
        debit = 0
        credit = -amount
      end
      @opening_balance_item = @opening_balance.opening_balance_items.build
      @opening_balance_item.organization_id = @organization.id
      @opening_balance_item.accounting_period_id = @accounting_period.id
      @opening_balance_item.account_id = @account.id
      @opening_balance_item.description = @account.description
      @opening_balance_item.debit = debit
      @opening_balance_item.credit = credit
      @opening_balance_item.save
    end
  end
end
