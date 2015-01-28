class WagePeriodsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /wage_periods
  # GET /wage_periods.json
  def index
    @breadcrumbs = [['Wage periods']]
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
    @wage_periods = current_organization.wage_periods.where('accounting_period_id=?', @period)
    @wage_periods = @wage_periods.page(params[:page]).decorate
  end

  # GET /wage_periods/new
  def new
    @accounting_period = current_organization.accounting_periods.find(session[:accounting_period_id])
    @wage_period = @accounting_period.next_wage_period
  end

  # GET /wage_periods/1
  def show
  end

  # GET /wage/1/edit
  def edit
  end

  # POST /wage_periods
  # POST /wage_periods.json
  def create
    @wage_period = WagePeriod.new(wage_period_params)
    @wage_period.organization = current_organization
    respond_to do |format|
      if @wage_period.save
        format.html { redirect_to wage_periods_url, notice: "#{t(:wage_period)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:wage_period)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /wage_periods/1
  # PATCH/PUT /wage_periods/1.json
  def update
    respond_to do |format|
      if @wage_period.update(wage_period_params)
        format.html { redirect_to wage_periods_url, notice: "#{t(:wage_period)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:wage_period)}"
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /wage_periods/1
  # DELETE /wage_periods/1.json
  def destroy
    @wage_period.destroy
    respond_to do |format|
      format.html { redirect_to wage_periods_url, notice: "#{t(:wage_period)} #{t(:was_successfully_deleted)}"}
    end
  end

  def create_wage
    @accounting_period = current_organization.accounting_periods.find(@wage_period.accounting_period_id)
    @wage_creator = Services::WageCreator.new(current_organization, current_user, @wage_period)
    @wage_creator.save_wages
    respond_to do |format|
      format.html { redirect_to wage_period_wages_path(@wage_period), notice: 'wage was successfully created.'}
    end
  end

  def create_wage_verificate
    @verificate_creator = Services::VerificateCreator.new(current_organization, current_user, @wage_period)
    respond_to do |format|
      if @verificate_creator.save_wage
        format.html { redirect_to verificates_url, notice: 'wage period was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:wage_period)}"
        format.html { render action: 'show' }
      end
    end
  end

  def create_wage_report
    @wage_report_creator = Services::WageReportCreator.new(current_organization, current_user, @wage_period)
    @wage_report_creator.delete_wage_report
    respond_to do |format|
      if @wage_report_creator.save_report
        format.html { redirect_to wage_period_wage_reports_url(@wage_period), notice: 'Wage report was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:wage_report)}"
        format.html { render action: 'show' }
      end
    end
  end

  def create_report_verificate
    @verificate_creator = Services::VerificateCreator.new(current_organization, current_user, @wage_period)
    respond_to do |format|
      if @verificate_creator.save_wage_report
        format.html { redirect_to verificates_url, notice: 'wage period was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:wage_period)}"
        format.html { render action: 'show' }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def wage_period_params
    params.require(:wage_period).permit(WagePeriod.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Wage periods', wage_periods_path], ["#{t(:new)} #{t(:wage_period)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Wage periods', wage_periods_path], [@wage_period.name]]
  end
end
