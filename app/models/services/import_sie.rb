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
      ver_id = 0
      IO.foreach('EXPORT.SE') do |line|
        case @sietyp
          when '4'
            set_ib(line) if line.starts_with?('#IB')
            ver_id = set_ver(line) if line.starts_with?('#VER')
            set_trans(ver_id, line) if line.starts_with?('#TRANS')
            close_verificate(ver_id) if line.starts_with?('}')
          else
        end
        set_type(line) if line.starts_with?('#SIETYP')
      end
    end

    def set_type(line)
      @sietyp = line.from(7).strip
    end

    def set_ib(line)
      #type, period, account, amount
      field = line.split(' ')
      save_opening_balance_item(field[2], field[3])
    end

    def set_ver(line)
      #type, serie, vernr date, text, regdate
      field = line.split(' ')
      text = line.split('"')
      return save_verificate(field[2], field[3], text[1])
    end

    def set_trans(ver_id, line)
      #type, account, {}, amount date
      field = line.split(' ')
      save_verificate_item(ver_id, field[1], field[3])
    end

    def save_opening_balance_item(number, amount)
      #OBS konton som inte finns
      @account = @accounting_plan.accounts.where('number = ?', number).first
      sum = BigDecimal.new(amount)
      if sum > 0
        debit = sum
        credit = 0
      else
        debit = 0
        credit = -sum
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

    def save_verificate(number, date, text)
      verificate = Verificate.new
      verificate.posting_date = date
      verificate.description = text
      verificate.organization_id = @organization.id
      verificate.accounting_period_id = @accounting_period.id
      verificate.save
      return verificate.id
    end

    def save_verificate_item(ver_id, number, amount)
      number == '3041' ? number = '3001' : number = number
      Rails.logger.info "#{ver_id.to_s}"
      @verificate = @accounting_period.verificates.where('id = ?', ver_id).first
      @account = @accounting_plan.accounts.where('number = ?', number).first
      sum = BigDecimal.new(amount)
      if sum > 0
        debit = sum
        credit = 0
      else
        debit = 0
        credit = -sum
      end
      verificate_item = @verificate.verificate_items.build
      verificate_item.organization = @organization
      verificate_item.accounting_period = @verificate.accounting_period
      verificate_item.account_id = @account.id
      verificate_item.description = @account.description
      verificate_item.debit = debit
      verificate_item.credit = credit
      verificate_item.save
    end

    def close_verificate(ver_id)
      @verificate = @accounting_period.verificates.where('id = ?', ver_id).first
      if @verificate.balanced?
        @verificate.state_change('mark_final')
      end
    end
  end
end
