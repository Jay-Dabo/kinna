class AccountingPeriodDecorator < Draper::Decorator
  delegate_all

  def accounting_from
    return l(object.accounting_from, format: "%Y-%m-%d") if object.accounting_from
    ""
  end

  def accounting_to
    return l(object.accounting_to, format: "%Y-%m-%d") if object.accounting_to
    ""
  end

end
