class WagesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :wage_period, through: :current_organization
  load_and_authorize_resource :wage, through: :wage_period

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /wages
  # GET /wages.json
  def index
    @breadcrumbs = [['Wage periods', wage_periods_path],
                    [@wage_period.name, wage_period_path(@wage_period.id)],
                    ['Wages']]
    @wage_periods = current_organization.wage_periods.order('id')
    if !params[:wage_period_id] && @wage_periods.count > 0
      params[:wage_period_id] = @wage_periods.first.id
    end
    @wages = current_organization.wages.where('wage_period_id=?', params[:wage_period_id])
    @wages = @wages.page(params[:page]).decorate
  end

  # GET /wages/new
  def new
    @wage_periods = current_organization.wage_periods
  end

  # GET /wages/1
  def show

  end

  # GET /wage/1/edit
  def edit
    @wage_periods = current_organization.wage_periods
  end

  # POST /wages
  # POST /wages.json
  def create
    @wage = Wage.new(wage_params)
    @wage.organization = current_organization
    respond_to do |format|
      if @wage.save
        format.html { redirect_to wages_url, notice: 'wage period was successfully created.' }
      else
        @wage_periods = current_organization.wage_periods
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:wage)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @wage.update(wage_params)
        format.html { redirect_to wages_url, notice: 'wage period was successfully updated.' }
      else
        @wage_periods = current_organization.wage_periods
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:wage)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @wage.destroy
    respond_to do |format|
      format.html { redirect_to wages_url, notice: 'wage period was successfully deleted.' }
    end
  end


  def wage_calculation_update
    respond_to do |format|
      if @wage.update(wage_params)
        @wage.state_change('mark_calculated', DateTime.now)
        format.html { redirect_to wages_url, notice: 'wage period was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:wage)}"
        format.html { render action: 'show' }
      end
    end
  end

  def wage_reporting
    @verificate_creator = Services::VerificateCreator.new(current_organization, current_user, @wage)
    respond_to do |format|
      if @verificate_creator.save_wage_report
        format.html { redirect_to verificate_url, notice: 'wage period was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:wage)}"
        format.html { render action: 'show' }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def wage_params
    params.require(:wage).permit(WagePeriod.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Wages', wages_path], ["#{t(:new)} #{t(:wage)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Wages', wages_path], [@wage.employee.name]]
  end
end
