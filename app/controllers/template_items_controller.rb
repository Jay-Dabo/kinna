class TemplateItemsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :template, through: :current_organization
  load_and_authorize_resource :template_item, through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [['Template item']]
  end

  # GET
  def new
    # segt
    # @accounting_plan = AccountingPlan.find(@template.accounting_plan)
    # @accounting_groups = @accounting_plan.accounting_groups
    @accounting_groups = current_organization.templates.find(@template).accounting_plan.accounting_groups
    gon.push accounting_groups: ActiveModel::ArraySerializer.new(@accounting_groups, each_serializer: AccountingGroupSerializer)
  end

  # GET
  def show
  end

  # GET
  def edit
  end

  # POST
  def create
    @template = current_organization.templates.find(params[:template_id])
    @template_item = @template.template_items.build template_item_params
    @template_item.organization = current_organization
    respond_to do |format|
      if @template_item.save
        format.html { redirect_to template_path(@template), notice: "#{t(:template_item)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:template_item)}"
        @accounting_groups = current_organization.templates.find(@template).accounting_plan.accounting_groups
        gon.push accounting_groups: ActiveModel::ArraySerializer.new(@accounting_groups, each_serializer: AccountingGroupSerializer)
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @template_item.update(template_item_params)
        format.html { redirect_to template_path(@template), notice: "#{t(:template_item)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:template_item)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @template_item.destroy
    respond_to do |format|
      format.html { redirect_to template_path(@template), notice:  "#{t(:template_item)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def template_item_params
    params.require(:template_item).permit(TemplateItem.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:templates), templates_path], [@template.name, template_path(@template)], ["#{t(:new)} #{t(:template_item)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:templates), templates_path], [@template.name, template_plan_path(@template)], [@template_item.description]]
  end
end
