class AccountDecorator < Draper::Decorator
  delegate_all

  def tax_code_code
    return object.tax_code.code if object.tax_code
    ""
  end
end
