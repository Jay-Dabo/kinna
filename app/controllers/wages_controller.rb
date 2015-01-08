class WagesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /wages
  # GET /wages.json
  def index
    @breadcrumbs = [['wages']]
    @wage_periods = current_organization.wage_periods.order('id')
    if !params[:wage_period_id] && @wage_periods.count > 0
      params[:wage_period_id] = @wage_periods.first.id
    end
    @wages = current_organization.wages.where('wage_period_id=?', params[:wage_period_id])
    @wages = @wages.page(params[:page]).decorate
  end

  # GET /wages/new
  def new
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true).order('id')
    @wage = @accounting_periods.first.next_wage
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
    @wage = WagePeriod.new(wage_params)
    @wage.organization = current_organization
    respond_to do |format|
      if @wage.save
        format.html { redirect_to wages_url, notice: 'wage period was successfully created.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
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
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
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

  def wage_calculation
    @accounting_period = current_organization.accounting_periods.find(@wage.accounting_period_id)
    @accounting_plan = current_organization.accounting_plans.find(@accounting_period.accounting_plan_id)

    # Momspliktig försäljning
    @verificates = current_organization.verificates.where("accounting_period_id = ? AND state = 'final' AND posting_date >= ? AND posting_date <= ?", @wage.accounting_period_id, @wage.wage_from, @wage.wage_to).select(:id)
    @accounts = Account.where('accounting_plan_id = ? AND tax_base = 5', @accounting_plan.id).select(:id)
    @wage_base_sum = VerificateItem
    .where("verificate_id IN(?) AND account_id IN(?)", @verificates, @accounts)
    @tax_base = 'Momspliktig försäljning'

    # Utgående moms 25%
    @verificates = current_organization.verificates.where("accounting_period_id = ? AND state = 'final' AND posting_date <= ?", @wage.accounting_period_id, @wage.wage_to).select(:id)
    @accounts = Account.where('accounting_plan_id = ? AND tax_code = 10', @accounting_plan.id).select(:id)
    @wage_10_ib = OpeningBalanceItem
    .where("account_id IN(?)", @accounts)
    @wage_10_ver = VerificateItem
    .where("verificate_id IN(?) AND account_id IN(?)",@verificates, @accounts)
    @wage_10_text = 'Utgående moms 25%'

    # Utgående moms 12%
    @accounts = Account.where('accounting_plan_id = ? AND tax_code = 11', @accounting_plan.id).select(:id)
    @wage_11_ib = OpeningBalanceItem
    .where("account_id IN(?)", @accounts)
    @wage_11_ver = VerificateItem
    .where("verificate_id IN(?) AND account_id IN(?)",@verificates, @accounts)
    @wage_11_text = 'Utgående moms 12%'

    # Utgående moms 6%
    @accounts = Account.where('accounting_plan_id = ? AND tax_code = 12', @accounting_plan.id).select(:id)
    @wage_12_ib = OpeningBalanceItem
    .where("account_id IN(?)", @accounts)
    @wage_12_ver = VerificateItem
    .where("verificate_id IN(?) AND account_id IN(?)",@verificates, @accounts)
    @wage_12_text = 'Utgående moms 6%'

    # Ingående moms
    @accounts = Account.where('accounting_plan_id = ? AND tax_code = 48', @accounting_plan.id).select(:id)
    @wage_in_ib = OpeningBalanceItem
    .where("account_id IN(?)", @accounts)
    @wage_in_sum = VerificateItem
    .where("verificate_id IN(?) AND account_id IN(?)",@verificates, @accounts)
    @in_sum = 'Ingående moms'

    respond_to do |format|
      format.html { render action: 'wage_calculation' }
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
    @breadcrumbs = [['Wage periods', wages_path], ["#{t(:new)} #{t(:wage)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Wage periods', wages_path], [@wage.name]]
  end
end
