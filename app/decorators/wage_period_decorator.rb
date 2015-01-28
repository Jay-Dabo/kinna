class WagePeriodDecorator < Draper::Decorator
  delegate_all

  def wage_from
    return l(object.wage_from, format: "%Y-%m-%d") if object.wage_from
    ""
  end

  def wage_to
    return l(object.wage_to, format: "%Y-%m-%d") if object.wage_to
    ""
  end
  def deadline
    return l(object.deadline, format: "%Y-%m-%d") if object.deadline
    ""
  end
  def state
    l = 'default'
    case object.state
      when 'preliminary'
        l = 'info'
        str = h.t(:preliminary)
      when 'wage_calculated'
        l = 'warning'
        str = h.t(:wage_calculated)
      when 'wage_reported'
        l = 'warning'
        str = h.t(:wage_reported)
      when 'wage_closed'
        l = 'success'
        str = h.t(:wage_closed)
      when 'tax_calculated'
        l = 'warning'
        str = h.t(:tax_calculated)
      when 'tax_reported'
        l = 'warning'
        str = h.t(:tax_reported)
      when 'tax_closed'
        l = 'success'
        str = h.t(:tax_closed)
     end
    h.labelify(str, l)
  end
end
