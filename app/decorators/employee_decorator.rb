class EmployeeDecorator < Draper::Decorator
  delegate_all
  def begin
    return l(object.begin, format: "%Y-%m-%d") if object.begin
    ""
  end

  def ending
    return l(object.ending, format: "%Y-%m-%d") if object.ending
    ""
  end
end
