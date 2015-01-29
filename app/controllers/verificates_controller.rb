class VerificatesController < ApplicationController
  respond_to :html, :json
  #load_and_authorize_resource :accounting_period, through: :current_organization
  #load_and_authorize_resource :verificate, through: :accounting_period
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [['Verificates']]
    @accounting_periods = current_organization.accounting_periods.order('id')
    if params[:accounting_period_id]
      session[:accounting_period_id] = params[:accounting_period_id]
      @period = params[:accounting_period_id]
    elsif session[:accounting_period_id]
      @period = session[:accounting_period_id]
    else
      @period = @accounting_periods.last.id
      session[:accounting_period_id] = @period
    end
    @verificates = current_organization.verificates.where('accounting_period_id=?', @period).order(:number)
    @verificates = @verificates.order(:posting_date).page(params[:page]).decorate
  end

  # GET
  def new
    @accounting_period = current_organization.accounting_periods.find(session[:accounting_period_id])
    @verificate.accounting_period = @accounting_period
    @templates = current_organization.templates.where('accounting_plan_id = ?', @accounting_period.accounting_plan_id)
    gon.push root: AccountingPeriodSerializer.new(@accounting_period)
  end

  # GET
  def show
    @accounting_period = @verificate.accounting_period
    gon.push root: AccountingPeriodSerializer.new(@accounting_period)
  end

  # GET
  def edit
  end

  # POST
  def create
    if !params[:template].blank?
      template = current_organization.templates.find(params[:template])
      params[:verificate][:description] = template.description + params[:verificate][:description]
    end
    @verificate = Verificate.new(verificate_params)
    @verificate.organization = current_organization
    respond_to do |format|
      if @verificate.save
        format.html { redirect_to verificate_path(@verificate), notice: "#{t(:verificate)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:verificate)}"
        @accounting_period = @verificate.accounting_period
        gon.push root: AccountingPeriodSerializer.new(@accounting_period)
        @templates = current_organization.templates.where('accounting_plan_id = ?', @accounting_period.accounting_plan_id)
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @verificate.update(verificate_params)
        format.html { redirect_to verificates_path, notice: "#{t(:verificate)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:verificate)}"
        @accounting_period = @verificate.accounting_period
        gon.push root: AccountingPeriodSerializer.new(@accounting_period)
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @verificate.destroy
    respond_to do |format|
      format.html { redirect_to verificates_path, notice:  "#{t(:verificate)} #{t(:was_successfully_deleted)}" }
    end
  end

  def state_change
    authorize! :manage, @verificate
    if @verificate.state_change(params[:event], params[:state_change_at])
      msg_h = { notice: t(:success) }
    else
      msg_h = { alert: t(:fail) }
    end
    redirect_to verificates_url, msg_h
  end

  def add_verificate_items
    @verificate = current_organization.verificates.find(params[:id])
    @verificate_items_creator = Services::VerificateItemsCreator.new(current_organization, current_user, @verificate, params)
    respond_to do |format|
      if @verificate_items_creator.save
        @accounting_period = @verificate.accounting_period
        gon.push root: AccountingPeriodSerializer.new(@accounting_period)
        format.html { redirect_to verificate_path(@verificate), notice: "#{t(:verificate_items)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:verificates_items)}"
        @accounting_period = @verificate.accounting_period
        gon.push root: AccountingPeriodSerializer.new(@accounting_period)
        format.html {  redirect_to verificate_path(@verificate)}
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def verificate_params
    params.require(:verificate).permit(Verificate.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:verificates)}", verificates_path], ["#{t(:new)} #{t(:verificate)}"]]
  end

  def show_breadcrumbs
    @verificate.number ? bc = @verificate.number : bc = '*'
    @breadcrumbs = [["#{t(:verificates)}", verificates_path], [bc]]
  end
end
