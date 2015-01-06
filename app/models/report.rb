class Report
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize(accounting_period)
    @accounting_period = accounting_period
  end

  attr_accessor :accounting_period

  def persisted?
    false
  end
end
