class ImportBankFileDecorator < Draper::Decorator
  delegate_all

  def import_date
    return l(object.import_date, format: "%Y-%m-%d") if object.import_date
    ""
  end

  def from_date
    return l(object.from_date, format: "%Y-%m-%d") if object.from_date
    ""
  end

  def to_date
    return l(object.to_date, format: "%Y-%m-%d") if object.to_date
    ""
  end
end
