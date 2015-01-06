class VatPeriodsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /vats
  # GET /vats.json
  def index
    @breadcrumbs = [['Vat_periods']]
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
    if !params[:accounting_period_id] && @accounting_periods.count > 0
      params[:accounting_period_id] = @accounting_periods.first.id
    end
    @vat_periods = current_organization.vat_periods.where('accounting_period_id=?', params[:accounting_period_id])
    @vat_periods = @vat_periods.page(params[:page]).decorate
  end

  # GET /vats/new
  def new
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
    @vat_period = @accounting_periods.first.next_vat_period
  end

  # GET /vats/1
  def show

  end

  # GET /vat/1/edit
  def edit
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
  end

  # POST /vats
  # POST /vats.json
  def create
    @vat_period = VatPeriod.new(vat_period_params)
    @vat_period.organization = current_organization
    respond_to do |format|
      if @vat_period.save
        format.html { redirect_to vat_periods_url, notice: 'Vat period was successfully created.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:vat_period)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @vat_period.update(vat_period_params)
        format.html { redirect_to vat_periods_url, notice: 'Vat period was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:vat_period)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @vat_period.destroy
    respond_to do |format|
      format.html { redirect_to vat_periods_url, notice: 'Vat period was successfully deleted.' }
    end
  end

  def vat_calculation
    @accounting_period = current_organization.accounting_periods.find(@vat_period.accounting_period_id)
    @accounting_plan = current_organization.accounting_plans.find(@accounting_period.accounting_plan_id)

    # Momspliktig försäljning
    @verificates = current_organization.verificates.where("accounting_period_id = ? AND state = 'final' AND posting_date >= ? AND posting_date <= ?", @vat_period.accounting_period_id, @vat_period.vat_from, @vat_period.vat_to).select(:id)
    @accounts = Account.where('accounting_plan_id = ? AND tax_base = 5', @accounting_plan.id).select(:id)
    @vat_base_sum = VerificateItem
    .where("verificate_id IN(?) AND account_id IN(?)", @verificates, @accounts)
    @tax_base = 'Momspliktig försäljning'

    # Utgående moms 25%
    @verificates = current_organization.verificates.where("accounting_period_id = ? AND state = 'final' AND posting_date <= ?", @vat_period.accounting_period_id, @vat_period.vat_to).select(:id)
    @accounts = Account.where('accounting_plan_id = ? AND tax_code = 10', @accounting_plan.id).select(:id)
    @vat_10_ib = OpeningBalanceItem
    .where("account_id IN(?)", @accounts)
    @vat_10_ver = VerificateItem
    .where("verificate_id IN(?) AND account_id IN(?)",@verificates, @accounts)
    @vat_10_text = 'Utgående moms 25%'

    # Utgående moms 12%
    @accounts = Account.where('accounting_plan_id = ? AND tax_code = 11', @accounting_plan.id).select(:id)
    @vat_11_ib = OpeningBalanceItem
    .where("account_id IN(?)", @accounts)
    @vat_11_ver = VerificateItem
    .where("verificate_id IN(?) AND account_id IN(?)",@verificates, @accounts)
    @vat_11_text = 'Utgående moms 12%'

    # Utgående moms 6%
    @accounts = Account.where('accounting_plan_id = ? AND tax_code = 12', @accounting_plan.id).select(:id)
    @vat_12_ib = OpeningBalanceItem
    .where("account_id IN(?)", @accounts)
    @vat_12_ver = VerificateItem
    .where("verificate_id IN(?) AND account_id IN(?)",@verificates, @accounts)
    @vat_12_text = 'Utgående moms 6%'

    # Ingående moms
    @accounts = Account.where('accounting_plan_id = ? AND tax_code = 48', @accounting_plan.id).select(:id)
    @vat_in_ib = OpeningBalanceItem
    .where("account_id IN(?)", @accounts)
    @vat_in_sum = VerificateItem
    .where("verificate_id IN(?) AND account_id IN(?)",@verificates, @accounts)
    @in_sum = 'Ingående moms'

    respond_to do |format|
      format.html { render action: 'vat_calculation' }
    end
  end

  def vat_calculation_update
    respond_to do |format|
      if @vat_period.update(vat_period_params)
        @vat_period.state_change('mark_calculated', DateTime.now)
        format.html { redirect_to vat_periods_url, notice: 'Vat period was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:vat_period)}"
        format.html { render action: 'show' }
      end
    end
  end

  def vat_reporting
    @verificate_creator = Services::VerificateCreator.new(current_organization, current_user, @vat_period)
    respond_to do |format|
      if @verificate_creator.save_vat_report
        format.html { redirect_to verificate_url, notice: 'Vat period was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:vat_period)}"
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
