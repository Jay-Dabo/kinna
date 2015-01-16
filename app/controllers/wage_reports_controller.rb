class WageReportsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :wage_period, through: :current_organization
  load_and_authorize_resource :wage_report, through: :wage_period

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /wages
  # GET /wages.json
  def index
    @breadcrumbs = [['Wage periods', wage_periods_path],
                    [@wage_period.name, wage_period_path(@wage_period.id)],
                    ['Wage report']]
    @wage_reports = @wage_period.wage_reports
    @wage_reports = @wage_reports.page(params[:page])
  end

  # GET /wages/new
  def new
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true).order('id')
    @wage_base = @accounting_periods.first.next_wage_base
  end

  # GET /wages/1
  def show
    @wage_period = WagePeriod.find(@wage_report.wage_period_id)
    @tax_code = TaxCode.find(params[:tax_code_id])
    @wage_report_creator = Services::WageReportCreator.new(current_organization, current_user, @wage_period)
    @items = @wage_report_creator.tax_code_part(@tax_code)
    Rails.logger.info "#{@items[0].inspect}"
    respond_to do |format|
      format.html { render action: 'show' }
    end
  end

  # GET /wage/1/edit
  def edit
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
  end

  # POST /wages
  # POST /wages.json
  def create
    @wage_base = wagePeriod.new(wage_base_params)
    @wage_base.organization = current_organization
    respond_to do |format|
      if @wage_base.save
        format.html { redirect_to wage_bases_url, notice: 'wage period was successfully created.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:wage_base)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @wage_base.update(wage_base_params)
        format.html { redirect_to wage_bases_url, notice: 'wage period was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:wage_base)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @wage_base.destroy
    respond_to do |format|
      format.html { redirect_to wage_bases_url, notice: 'wage period was successfully deleted.' }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def wage_base_params
    params.require(:wage_base).permit(wagePeriod.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['wage reports', wage_reports_path], ["#{t(:new)} #{t(:wage_report)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Wage periods', wage_periods_path], [@wage_report.wage_period.name, wage_period_path(@wage_report.wage_period_id)],
                    ['Wage reports', wage_period_wage_reports_path(@wage_report.wage_period_id)],
                    [@wage_report.tax_code.code]]
  end
end
