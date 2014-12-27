class ClosingBalanceItemDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  delegate_all

  def debit
    number_with_precision(object.debit, precision: 2)
  end
  def credit
    number_with_precision(object.credit, precision: 2)
  end
  def total_debit
    number_with_precision(object.total_debit, precision: 2)
  end
  def total_credit
    number_with_precision(object.total_credit, precision: 2)
  end
end
