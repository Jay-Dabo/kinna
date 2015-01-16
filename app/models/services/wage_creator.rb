module Services
  class WageCreator

    def initialize(organization, user, wage_period)
      @user = user
      @organization = organization
      @wage_period = wage_period
    end

    def save_wages
      @accounting_period = AccountingPeriod.find(@wage_period.accounting_period_id)
      employee = @organization.employees.where('begin < ? AND ending > ?', @wage_period.wage_to, @wage_period.wage_from)
      employee.each do |employee|
        proc = 0
        age = DateTime.now.strftime('%Y').to_i
        Rails.logger.info "---#{age}"
        age = age - employee.birth_year
        Rails.logger.info "---#{age}"
        case age
          when 0..26
            proc = BigDecimal.new("0.1549")
          when 26..65
            proc = BigDecimal.new("0.3142")
          when 65..99
            proc = BigDecimal.new("0.1021")
          else
            proc = 1
        end
        payroll_tax = (employee.salary * proc).round
        save_wage(employee, employee.salary, employee.tax, payroll_tax, @accounting_period, @wage_period)
      end
      @wage_period.state_change('mark_wage_calculated', DateTime.now)
    end

    def save_wage(employee, salary, tax, payroll_tax, accounting_period, wage_period)
      wage = Wage.new
      wage.employee = employee
      wage.wage_from = wage_period.wage_from
      wage.wage_to = wage_period.wage_to
      wage.payment_date = wage_period.payment_date
      wage.salary = salary
      wage.tax = tax
      wage.payroll_tax = payroll_tax
      wage.amount = salary - tax
      wage.organization = @organization
      wage.accounting_period = accounting_period
      wage.wage_period = wage_period
      wage.save
    end
  end
end
