class TaxReturnDecorator < Draper::Decorator
  delegate_all

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
     end
    h.labelify(str, l)
  end
end
