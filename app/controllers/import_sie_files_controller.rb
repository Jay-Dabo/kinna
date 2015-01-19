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
        if params[:import_sie_file][:import_type] == 'IB'
          accounting_period = current_organization.accounting_periods.find(params[:import_sie_file][:accounting_period])
          accounting_plan = accounting_period.accounting_plan
          @import_sie = Services::ImportSie.new(current_organization, current_user, accounting_period, accounting_plan)
          if @import_sie.read_ib_and_save
            format.html { redirect_to opening_balance_path(accounting_period.opening_balance), notice: "#{t(:opening_balance)} #{t(:was_successfully_created)}" }
          else
            flash.now[:danger] = "#{t(:failed_to_update)} #{t(:opening_balance)}"
            format.html { redirect_to opening_balances_url }
          end
        else
          flash.now[:danger] = "#{t(:failed_to_create)} #{t(:vat_period)}"
          format.html { render action: 'order_import_sie' }
        end
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:vat_period)}"
        @accounting_periods = current_organization.accounting_periods
        format.html { render action: 'order_import_sie' }
      end
    end
  end

  private

end
