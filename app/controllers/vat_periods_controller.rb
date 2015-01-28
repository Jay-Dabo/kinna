class VatPeriodsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  def index
    @breadcrumbs = [['Vat periods']]
    @accounting_periods = current_organization.accounting_periods.order('id')
    if params[:accounting_period_id]
      session[:accounting_period_id] = params[:accounting_period_id]
      @period = params[:accounting_period_id]
    elsif session[:accounting_period_id]
      @period = session[:accounting_period_id]
    else
      @period = @accounting_periods.last.id
      session[:accounting_period_id] = @period
    end
    @vat_periods = current_organization.vat_periods.where('accounting_period_id=?', @period).order('id')
    @vat_periods = @vat_periods.page(params[:page]).decorate
  end

  def new
    @accounting_period = current_organization.accounting_periods.find(session[:accounting_period_id])
    @vat_period = @accounting_period.next_vat_period
  end

  def show
  end

  def edit
  end

  def create
    @vat_period = VatPeriod.new(vat_period_params)
    @vat_period.organization = current_organization
    respond_to do |format|
      if @vat_period.save
          format.html { redirect_to vat_periods_path, notice: "#{t(:vat_period)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:vat_period)}"
        format.html { render action: 'new' }
      end
    end
  end

  def update
    respond_to do |format|
      if @vat_period.update(vat_period_params)
        format.html { redirect_to vat_periods_path, notice: "#{t(:vat_period)} #{t(:was_successfully_updated)}"}
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:vat_period)}"
        format.html { render action: 'edit' }
      end
    end
  end

  def destroy
    @vat_period.destroy
    respond_to do |format|
      format.html { redirect_to vat_periods_path, notice: "#{t(:vat_period)} #{t(:was_successfully_deleted)}"}
    end
  end

  def create_vat_report
    # till status calculate
    @vat_report_creator = Services::VatReportCreator.new(current_organization, current_user, @vat_period)
    @vat_report_creator.delete_vat_report
    respond_to do |format|
      if @vat_report_creator.save_report
        format.html { redirect_to vat_period_vat_reports_url(@vat_period), notice: 'Vat report was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:vat_report)}"
        format.html { render action: 'show' }
      end
    end
  end

  def create_verificate
    # till status
    @verificate_creator = Services::VerificateCreator.new(current_organization, current_user, @vat_period)
    respond_to do |format|
      if @verificate_creator.save_vat_report
        format.html { redirect_to verificates_url, notice: 'Vat report was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:vat_report)}"
        format.html { render action: 'show' }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def vat_period_params
    params.require(:vat_period).permit(VatPeriod.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Vat periods', vat_periods_path], ["#{t(:new)} #{t(:vat_period)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Vat periods', vat_periods_path], [@vat_period.name]]
  end
end
