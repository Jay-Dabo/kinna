class VatPeriodDecorator < Draper::Decorator
  delegate_all

  def vat_from
    return l(object.vat_from, format: "%Y-%m-%d") if object.vat_from
    ""
  end

  def vat_to
    return l(object.vat_to, format: "%Y-%m-%d") if object.vat_to
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
      when 'calculated'
        l = 'warning'
        str = h.t(:calculated)
      when 'reported'
        l = 'success'
        str = h.t(:reported)
      when 'closed'
        l = 'success'
        str = h.t(:closed)
     end
    h.labelify(str, l)
  end
end
