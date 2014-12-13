class AccountingPlansController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /vats
  # GET /vats.json
  def index
    @breadcrumbs = [['Accounting_plans']]
    @accounting_plans = current_organization.accounting_plans.order(:name)
    @accounting_plans = @accounting_plans.page(params[:page])
  end

  # GET /vats/new
  def new
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
    @accounting_plan = AccountingPlan.new(accounting_plan_params)
    @accounting_plan.organization = current_organization
    respond_to do |format|
      if @accounting_plan.save
        format.html { redirect_to accounting_plans_url, notice: 'Account plan was successfully created.' }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{"Accounting_plan"}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @accounting_plan.update(accounting_plan_params)
        format.html { redirect_to accounting_plans_url, notice: 'Account plan was successfully updated.' }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:accounting_plan)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @accounting_plan.destroy
    respond_to do |format|
      format.html { redirect_to accounting_plans_url, notice: 'Account plan was successfully deleted.' }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def accounting_plan_params
    params.require(:accounting_plan).permit(AccountingPlan.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Accounting plans', accounting_plans_path], ["#{t(:new)} #{t(:accounting_plan)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Accounting plans', accounting_plans_path], [@accounting_plan.name]]
  end
end
