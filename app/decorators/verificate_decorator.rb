class VerificateDecorator < Draper::Decorator
  delegate_all

  def posting_date
    return l(object.posting_date, format: "%Y-%m-%d") if object.posting_date
    ""
  end
  def parent
    return object.vat_period.name if object.vat_period
    return object.wage_period_wage.name if object.wage_period_wage
    return object.wage_period_report.name if object.wage_period_report
    ""
  end
  def total_debit
    number_with_precision(object.total_debit, precision: 2)
  end
  def total_credit
    number_with_precision(object.total_credit, precision: 2)
  end
  def pretty_state
    l = 'default'
    case object.state
      when 'preliminary'
        l = 'info'
        str = h.t(:preliminary)
      when 'final'
        l = 'success'
        str = h.t(:final)
     end
    h.labelify(str, l)
  end
end
