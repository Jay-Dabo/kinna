class LedgerTransactionDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  delegate_all

  def posting_date
    return l(object.posting_date, format: "%Y-%m-%d") if object.posting_date
    ""
  end
  def sum
    number_with_precision(object.sum, precision: 2)
  end
end
