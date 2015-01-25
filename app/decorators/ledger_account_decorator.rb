class LedgerAccountDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  delegate_all

  def sum
    number_with_precision(object.sum, precision: 2)
  end
end
