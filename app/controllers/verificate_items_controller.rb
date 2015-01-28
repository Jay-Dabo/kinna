class VerificateItemsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :verificate, through: :current_organization
  load_and_authorize_resource :verificate_item, through: :verificate

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [['Verificate item']]
  end

  # GET
  def new
    @accounting_groups = current_organization.accounting_plan.accounting_groups
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
    @verificate = current_organization.verificates.find(params[:verificate_id])
    @verificate_item = @verificate.verificate_items.build verificate_item_params
    @verificate_item.organization = current_organization
    @verificate_item.accounting_period = @verificate.accounting_period
    respond_to do |format|
      if @verificate_item.save
        format.html { redirect_to verificate_path(@verificate), notice: "#{t(:verificate_item)} #{t(:was_successfully_created)}" }
      else
        @accounting_groups = current_organization.accounting_plan.accounting_groups
        gon.push accounting_groups: ActiveModel::ArraySerializer.new(@accounting_groups, each_serializer: AccountingGroupSerializer)
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:verificate_item)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @verificate_item.update(verificate_item_params)
        format.html { redirect_to verificate_path(@verificate), notice: "#{t(:verificate_item)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:verificate_item)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @verificate_item.destroy
    respond_to do |format|
      format.html { redirect_to verificate_path(@verificate), notice:  "#{t(:verificate_item)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def verificate_item_params
    params.require(:verificate_item).permit(VerificateItem.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @verificate.number ? bc = @verificate.number : bc = '*'
    @breadcrumbs = [[t(:verificates), verificates_path], [bc, verificate_path(@verificate)], ["#{t(:new)} #{t(:verificate_item)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:verificates), verificates_path], [@verificate.number, verificate_plan_path(@verificate)], [@verificate_item.description]]
  end
end
