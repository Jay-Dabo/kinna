module Services
  class ImportSie
    def initialize(organization, user, accounting_period, accounting_plan)
      @user = user
      @organization = organization
      @accounting_plan = accounting_plan
      @accounting_period = accounting_period
      @opening_balance = accounting_period.opening_balance
      @closing_balance = accounting_period.closing_balance
      @sietyp = ''
    end

    def read_and_save(import_type)
      save_closing_balance if @closing_balance.nil? && import_type == 'UB'
      save_opening_balance if @opening_balance.nil? && import_type == 'IB'
      ver_id = 0
      IO.foreach('EXPORT.SE') do |line|
        case @sietyp
          when '4'
            set_ub(line) if line.starts_with?('#UB') if import_type == 'UB'
            set_ib(line) if line.starts_with?('#IB') if import_type == 'IB'
            ver_id = set_ver(line) if line.starts_with?('#VER') if import_type == "Transactions"
            set_trans(ver_id, line) if line.starts_with?('#TRANS') if import_type == "Transactions"
            close_verificate(ver_id) if line.starts_with?('}') if import_type == "Transactions"
          else
        end
        set_type(line) if line.starts_with?('#SIETYP')
      end
      return true
    end

    def set_type(line)
      @sietyp = line.from(7).strip
    end

    def set_ib(line)
      #type, period, account, amount
      field = line.split(' ')
      set_opening_balance_item(field[2], field[3])
    end

    def set_ub(line)
      #type, period, account, amount
      field = line.split(' ')
      set_closing_balance_item(field[2], field[3])
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
      set_verificate_item(ver_id, field[1], field[3])
    end

    def save_opening_balance
      @opening_balance = OpeningBalance.new
      @opening_balance.posting_date = DateTime.now
      @opening_balance.description = 'Imported'
      @opening_balance.organization = @organization
      @opening_balance.accounting_period = @accounting_period
      @opening_balance.save
    end

    def save_closing_balance
      @closing_balance = ClosingBalance.new
      @closing_balance.posting_date = DateTime.now
      @closing_balance.description = 'Imported'
      @closing_balance.organization = @organization
      @closing_balance.accounting_period = @accounting_period
      @closing_balance.save
    end

    def set_opening_balance_item(number, amount)
      @account = get_diff_account(number)
      @account = @accounting_plan.accounts.where('number = ?', number).first if @account.nil?
      set_diff_account(number) if @account.nil?
      return if @account.nil?

      sum = BigDecimal.new(amount)
      if sum > 0
        debit = sum
        credit = 0
      else
        debit = 0
        credit = -sum
      end

      @opening_balance_item = @opening_balance.opening_balance_items.where('account_id = ?', @account.id).first
      if @opening_balance_item.nil?
        create_opening_balance_item(@account, debit, credit)
      else
        update_opening_balance_item(@opening_balance_item, debit, credit)
      end
    end

    def set_closing_balance_item(number, amount)
      @account = get_diff_account(number)
      @account = @accounting_plan.accounts.where('number = ?', number).first if @account.nil?
      set_diff_account(number) if @account.nil?
      return if @account.nil?

      sum = BigDecimal.new(amount)
      if sum > 0
        debit = sum
        credit = 0
      else
        debit = 0
        credit = -sum
      end

      @closing_balance_item = @closing_balance.closing_balance_items.where('account_id = ?', @account.id).first
      if @closing_balance_item.nil?
        create_closing_balance_item(@account, debit, credit)
      else
        update_closing_balance_item(@closing_balance_item, debit, credit)
      end
    end

    def create_opening_balance_item(account, debit, credit)
      @opening_balance_item = @opening_balance.opening_balance_items.build
      @opening_balance_item.organization_id = @organization.id
      @opening_balance_item.accounting_period_id = @accounting_period.id
      @opening_balance_item.account_id = account.id
      @opening_balance_item.description = account.description
      @opening_balance_item.debit = debit
      @opening_balance_item.credit = credit
      @opening_balance_item.save
    end

    def update_opening_balance_item(opening_balance_item, debit, credit)
      opening_balance_item.debit += debit
      opening_balance_item.credit += credit
      opening_balance_item.save
    end


    def create_closing_balance_item(account, debit, credit)
      @closing_balance_item = @closing_balance.closing_balance_items.build
      @closing_balance_item.organization_id = @organization.id
      @closing_balance_item.accounting_period_id = @accounting_period.id
      @closing_balance_item.account_id = account.id
      @closing_balance_item.description = account.description
      @closing_balance_item.debit = debit
      @closing_balance_item.credit = credit
      @closing_balance_item.save
    end

    def update_closing_balance_item(opening_balance_item, debit, credit)
      opening_balance_item.debit += debit
      opening_balance_item.credit += credit
      opening_balance_item.save
    end

    def get_diff_account(number)
      conversion = @organization.conversions.where('old_number = ?', number).first
      return nil if conversion.nil?
      @account = @accounting_plan.accounts.where('number = ?', conversion.new_number).first
      return @account
    end

    def set_diff_account(number)
        conversion = Conversion.new
        conversion.old_number = number
        conversion.organization = @organization
        conversion.save
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

    def set_verificate_item(ver_id, number, amount)
      account = get_diff_account(number)
      account = @accounting_plan.accounts.where('number = ?', number).first if account.nil?
      set_diff_account(number) if account.nil?
      return if account.nil?

      sum = BigDecimal.new(amount)
      if sum > 0
        debit = sum
        credit = 0
      else
        debit = 0
        credit = -sum
      end
      save_verificate_item(ver_id, account, debit, credit)
    end

    def save_verificate_item(ver_id, account, debit, credit)
      @verificate = @accounting_period.verificates.where('id = ?', ver_id).first

      verificate_item = @verificate.verificate_items.build
      verificate_item.organization = @organization
      verificate_item.accounting_period = @verificate.accounting_period
      verificate_item.account_id = account.id
      verificate_item.description = account.description
      verificate_item.debit = debit
      verificate_item.credit = credit
      verificate_item.save
    end

    def close_verificate(ver_id)
      @verificate = @accounting_period.verificates.where('id = ?', ver_id).first
      if @verificate.balanced?
        @verificate.state_change('mark_final', @verificate.posting_date)
      end
    end
  end
end
