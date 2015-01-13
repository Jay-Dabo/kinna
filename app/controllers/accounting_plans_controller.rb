class AccountingPlansController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /accounting_plans
  # GET /accounting_plans.json
  def index
    @breadcrumbs = [["#{t(:accounting_plans)}"]]
    init
  end

  # GET /accounting_plan/new
  def new
  end

  # GET /accounting_plan/1
  def show
  end

  # GET /vat/1/edit
  def edit
  end

  # POST /accounting_plan
  # POST /accounting_plan.json
  def create
    @accounting_plan = AccountingPlan.new(accounting_plan_params)
    @accounting_plan.organization = current_organization
    respond_to do |format|
      if @accounting_plan.save
        format.html { redirect_to accounting_plans_url, notice: "#{t(:accounting_plan)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:accounting_plan)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /accounting_plan/1
  # PATCH/PUT /accounting_plan/1.json
  def update
    respond_to do |format|
      if @accounting_plan.update(accounting_plan_params)
        format.html { redirect_to accounting_plans_url, notice: "#{t(:accounting_plan)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:accounting_plan)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /accounting_plan/1
  # DELETE /accounting_plan/1.json
  def destroy
    @accounting_plan.destroy
    respond_to do |format|
      format.html { redirect_to accounting_plans_url, notice: "#{t(:accounting_plan)} #{t(:was_successfully_deleted)}" }
    end
  end

  def import
    @accounting_plan_creator = Services::AccountingPlanCreator.new(current_organization, current_user)
    respond_to do |format|
      if @accounting_plan_creator.BAS_read_and_save
        format.html { redirect_to accounting_plans_url, notice: "#{t(:accounting_plan)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:accounting_plan)}"
        format.html { redirect_to accounting_plans_url }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def accounting_plan_params
    params.require(:accounting_plan).permit(AccountingPlan.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:accounting_plan)}", accounting_plans_path], ["#{t(:new)} #{t(:accounting_plan)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [["#{t(:accounting_plan)}", accounting_plans_path], [@accounting_plan.name]]
  end

  def init
    @accounting_plans = current_organization.accounting_plans.order(:name)
    @accounting_plans = @accounting_plans.page(params[:page]).decorate
  end
end
