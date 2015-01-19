class ImportBankFileRowDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  delegate_all

  def posting_date
    return l(object.posting_date, format: "%Y-%m-%d") if object.posting_date
    ""
  end

  def amount_formatted
    number_with_precision(object.amount, precision: 2)
  end

end
