class ImportSieFile
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  def initialize(current_organization)
    @current_organization = current_organization
  end

  validate :check_ib

  def check_ib
    @accounting_period = @current_organization.accounting_periods.where('id = ?', accounting_period_id.to_i).first
    return true if @accounting_period.opening_balance.nil?
    errors.add(:import_type, I18n.t(:already_exists))
  end

  attr_accessor :accounting_period, :accounting_period_id, :import_type

  def persisted?
    false
  end
end
