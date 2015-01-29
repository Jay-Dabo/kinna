class TemplatesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [['Templates']]
    @accounting_plans = current_organization.accounting_plans.order('id')
    if params[:accounting_plan_id]
      @templates = current_organization.templates.where('accounting_plan_id=?', params[:accounting_plan_id]).order(:name)
    else
      @templates = current_organization.templates.where('accounting_plan_id=?', @accounting_plans.first.id).order(:name)
    end
    @templates = @templates.page(params[:page])
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
    @template = Template.new(template_params)
    @template.organization = current_organization
    respond_to do |format|
      if @template.save
        format.html { redirect_to template_path(@template), notice: "#{t(:template)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:template)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html { redirect_to templates_path, notice: "#{t(:template)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:template)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @template.destroy
    respond_to do |format|
      format.html { redirect_to templates_path, notice:  "#{t(:template)} #{t(:was_successfully_deleted)}" }
    end
  end


  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def template_params
    params.require(:template).permit(Template.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:templates)}", templates_path], ["#{t(:new)} #{t(:template)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [["#{t(:templates)}", templates_path], [@template.name]]
  end
end
