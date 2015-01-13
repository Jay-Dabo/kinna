class AccountingClassesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :accounting_plan, through: :current_organization
  load_and_authorize_resource :accounting_class, through: :accounting_plan

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [['Accounting classes']]
  end

  # GET
  def new
  end

  # GET
  def show
  end

  # GET
  def edit
  end

  # POST
  def create
    @accounting_plan = current_organization.accounting_plans.find(params[:accounting_plan_id])
    @accounting_class = @accounting_plan.accounting_classes.build accounting_class_params
    @accounting_class.organization = current_organization
    respond_to do |format|
      if @accounting_class.save
        format.html { redirect_to accounting_plan_path(@accounting_plan), notice: "#{t(:accounting_class)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:accounting_class)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @accounting_class.update(accounting_class_params)
        format.html { redirect_to accounting_plan_path(@accounting_plan), notice: "#{t(:accounting_class)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:accounting_class)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @accounting_class.destroy
    respond_to do |format|
      format.html { redirect_to accounting_plan_path(@accounting_plan), notice:  "#{t(:accounting_class)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def accounting_class_params
    params.require(:accounting_class).permit(AccountingClass.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:accounting_plans), accounting_plans_path], [@accounting_plan.name, accounting_plan_path(@accounting_plan)], ["#{t(:new)} #{t(:accounting_class)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:accounting_plans), accounting_plans_path], [@accounting_plan.name, accounting_plan_path(@accounting_plan)], [@accounting_class.name]]
  end
end
