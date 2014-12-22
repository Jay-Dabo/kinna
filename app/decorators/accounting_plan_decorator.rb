class AccountingPlanDecorator < Draper::Decorator
  delegate_all

  def active
    return h.labelify("active", "success") if object.active?
  end
end
