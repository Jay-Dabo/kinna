class ImportSieFilesController < ApplicationController
  respond_to :html, :json, :pdf

  def order_import_sie
    @breadcrumbs = [['Import SIE']]
    @import_sie_file = ImportSieFile.new(current_organization)
    @accounting_periods = current_organization.accounting_periods
  end

  def import_sie
    @import_sie_file = ImportSieFile.new(current_organization)
    @import_sie_file.accounting_period_id = params[:import_sie_file][:accounting_period]
    @import_sie_file.import_type = params[:import_sie_file][:import_type]

    respond_to do |format|
      if @import_sie_file.valid?
        import_type = params[:import_sie_file][:import_type]
        accounting_period = current_organization.accounting_periods.find(params[:import_sie_file][:accounting_period])
        accounting_plan = accounting_period.accounting_plan
        @import_sie = Services::ImportSie.new(current_organization, current_user, accounting_period, accounting_plan)
        if @import_sie.read_and_save(import_type)
          format.html { redirect_to opening_balance_path(accounting_period.opening_balance), notice: "#{t(:opening_balance)} #{t(:was_successfully_created)}" }
        else
          @accounting_periods = current_organization.accounting_periods
          flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import)}"
          format.html {render action: 'order_import_sie' }
        end
      else
        @accounting_periods = current_organization.accounting_periods
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import)}"
        format.html { render action: 'order_import_sie' }
      end
    end
  end

  private

end
