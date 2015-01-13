class ResultUnitsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /result_units
  # GET /result_units.json
  def index
    @breadcrumbs = [['Result units']]
    @result_units = current_organization.result_units.order(:name)
    @result_units = @result_units.page(params[:page])
  end

  # GET /result_units/new
  def new
  end

  # GET /result_units/1
  def show
  end

  # GET /result_unit/1/edit
  def edit
  end

  # POST /result_units
  # POST /result_units.json
  def create
    @result_unit = ResultUnit.new(result_unit_params)
    @result_unit.organization = current_organization
    respond_to do |format|
      if @result_unit.save
        format.html { redirect_to result_units_url, notice: "#{t(:result_unit)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:result_unit)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /result_units/1
  # PATCH/PUT /result_units/1.json
  def update
    respond_to do |format|
      if @result_unit.update(result_unit_params)
        format.html { redirect_to result_units_url, notice:  "#{t(:result_unit)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:result_unit)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /result_units/1
  # DELETE /result_units/1.json
  def destroy
    @result_unit.destroy
    respond_to do |format|
      format.html { redirect_to result_units_url, notice:  "#{t(:result_unit)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def result_unit_params
    params.require(:result_unit).permit(ResultUnit.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Result units', result_units_path], ["#{t(:new)} #{t(:result_unit)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Result units', result_units_path], [@result_unit.name]]
  end
end
