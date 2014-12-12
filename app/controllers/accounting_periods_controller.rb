class AccountingPeriodsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /vats
  # GET /vats.json
  def index
    @breadcrumbs = [['Accounting_periods']]
    @accounting_periods = current_organization.accounting_periods.order(:accounting_from)
    @accounting_periods = @accounting_periods.page(params[:page]).decorate
  end

  # GET /vats/new
  def new
    @accounting_period.name = t(:accounting_period) + " " + (Date.current.year + 1).to_s
    @accounting_period.accounting_from = Date.new(Date.current.year+1, 1, 1)
    @accounting_period.accounting_to = Date.new(Date.current.year+1, 12, 31)
  end

  # GET /vats/1
  def show
  end

  # GET /vat/1/edit
  def edit
  end

  # POST /vats
  # POST /vats.json
  def create
    @account_period = AccountingPeriod.new(accounting_period_params)
    @account_period.organization = current_organization
    respond_to do |format|
      if @accounting_period.save
        format.html { redirect_to accounting_periods_url, notice: 'Account period was successfully created.' }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:accounting_period)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @accounting_period.update(accounting_period_params)
        format.html { redirect_to accounting_periods_url, notice: 'Account period was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:accounting_period)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @accounting_period.destroy
    respond_to do |format|
      format.html { redirect_to accounting_periods_url, notice: 'Account period was successfully deleted.' }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def accounting_period_params
    params.require(:accounting_period).permit(AccountingPeriod.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Accounting periods', accounting_periods_path], ["#{t(:new)} #{t(:accounting_period)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Accounting periods', accounting_periods_path], [@accounting_period.name]]
  end
end
