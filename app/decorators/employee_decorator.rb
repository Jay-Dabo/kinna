class EmployeeDecorator < Draper::Decorator
  delegate_all
  def begin
    return l(object.begin, format: "%Y-%m-%d") if object.begin
    ""
  end

  def end
    return l(object.end, format: "%Y-%m-%d") if object.end
    ""
  end
end
