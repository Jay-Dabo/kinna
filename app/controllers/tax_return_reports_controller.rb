class TaxReturnReportsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :tax_return, through: :current_organization
  load_and_authorize_resource :tax_return_report, through: :tax_return

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /vats
  # GET /vats.json
  def index
    @breadcrumbs = [['Tax returns', tax_returns_path], [@tax_return.name, tax_return_path(@tax_return.id)],
                    ['Tax return reports']]
    @tax_returns = current_organization.tax_returns.order('id')
    if !params[:tax_return_id] && @tax_returns.count > 0
      params[:tax_return_id] = @tax_returns.first.id
    end
    @tax_return_reports = current_organization.tax_return_reports.where('tax_return_id=?', params[:tax_return_id])
    @tax_return_reports = @tax_return_reports.page(params[:page])
  end

  # GET /vats/new
  def new
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true).order('id')
    @vat_base = @accounting_periods.first.next_vat_base
  end

  # GET /vats/1
  def show
    @tax_return = TaxReturn.find(@tax_return_report.tax_return_id)
    @ink_code = InkCode.find(params[:ink_code_id])
    @tax_return_report_creator = Services::TaxReturnReportCreator.new(current_organization, current_user, @tax_return)
    @items = @tax_return_report_creator.ink_code_part(@ink_code)
    Rails.logger.info "#{@items[0].inspect}"
    respond_to do |format|
      format.html { render action: 'show' }
    end
  end

  # GET /vat/1/edit
  def edit
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
  end

  # POST /vats
  # POST /vats.json
  def create
    @vat_base = VatPeriod.new(vat_base_params)
    @vat_base.organization = current_organization
    respond_to do |format|
      if @vat_base.save
        format.html { redirect_to vat_bases_url, notice: 'Vat period was successfully created.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:vat_base)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @vat_base.update(vat_base_params)
        format.html { redirect_to vat_bases_url, notice: 'Vat period was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:vat_base)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @vat_base.destroy
    respond_to do |format|
      format.html { redirect_to vat_bases_url, notice: 'Vat period was successfully deleted.' }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def vat_base_params
    params.require(:vat_base).permit(VatPeriod.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Vat periods', vat_periods_path],['Vat reports', tax_return_reports_path], ["#{t(:new)} #{t(:tax_return_report)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Tax returns', tax_returns_path], [@tax_return.name, tax_return_path(@tax_return_report.tax_return_id)],
                    ['Tax return reports', tax_return_tax_return_reports_path(@tax_return_report.tax_return_id)],
                    [@tax_return_report.ink_code.code]]
  end
end
