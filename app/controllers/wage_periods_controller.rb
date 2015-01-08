class WagePeriodsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /wages
  # GET /wages.json
  def index
    @breadcrumbs = [['Wage_periods']]
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true).order('id')
    if !params[:accounting_period_id] && @accounting_periods.count > 0
      params[:accounting_period_id] = @accounting_periods.first.id
    end
    @wage_periods = current_organization.wage_periods.where('accounting_period_id=?', params[:accounting_period_id])
    @wage_periods = @wage_periods.page(params[:page]).decorate
  end

  # GET /wages/new
  def new
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true).order('id')
    @wage_period = @accounting_periods.first.next_wage_period
  end

  # GET /wages/1
  def show

  end

  # GET /wage/1/edit
  def edit
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
  end

  # POST /wages
  # POST /wages.json
  def create
    @wage_period = WagePeriod.new(wage_period_params)
    @wage_period.organization = current_organization
    respond_to do |format|
      if @wage_period.save
        format.html { redirect_to wage_periods_url, notice: 'wage period was successfully created.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:wage_period)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @wage_period.update(wage_period_params)
        format.html { redirect_to wage_periods_url, notice: 'wage period was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:wage_period)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @wage_period.destroy
    respond_to do |format|
      format.html { redirect_to wage_periods_url, notice: 'wage period was successfully deleted.' }
    end
  end

  def wage_calculation
    @accounting_period = current_organization.accounting_periods.find(@wage_period.accounting_period_id)
    @wage_creator = Services::WageCreator.new(current_organization, current_user, @wage_period)
    @wage_creator.save_wages
    respond_to do |format|
      format.html {redirect_to wages_url, notice: 'wage was successfully created.'}
    end
  end

  def wage_calculation_update
    respond_to do |format|
      if @wage_period.update(wage_period_params)
        @wage_period.state_change('mark_calculated', DateTime.now)
        format.html { redirect_to wage_periods_url, notice: 'wage period was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:wage_period)}"
        format.html { render action: 'show' }
      end
    end
  end

  def wage_reporting
    @verificate_creator = Services::VerificateCreator.new(current_organization, current_user, @wage_period)
    respond_to do |format|
      if @verificate_creator.save_wage_report
        format.html { redirect_to verificate_url, notice: 'wage period was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
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
