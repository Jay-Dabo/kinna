class ConversionsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /conversions
  # GET /conversions.json
  def index
    @breadcrumbs = [['Conversions']]
    @conversions = current_organization.conversions.order(:old_number)
    @conversions = @conversions.page(params[:page])
  end

  # GET /conversions/new
  def new
  end

  # GET /conversions/1
  def show
  end

  # GET /conversion/1/edit
  def edit
  end

  # POST /conversions
  # POST /conversions.json
  def create
    @conversion = Conversion.new(conversion_params)
    @conversion.organization = current_organization
    respond_to do |format|
      if @conversion.save
        format.html { redirect_to conversions_url, notice: "#{t(:conversion)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:conversion)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /conversions/1
  # PATCH/PUT /conversions/1.json
  def update
    respond_to do |format|
      if @conversion.update(conversion_params)
        format.html { redirect_to conversions_url, notice:  "#{t(:conversion)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:conversion)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /conversions/1
  # DELETE /conversions/1.json
  def destroy
    @conversion.destroy
    respond_to do |format|
      format.html { redirect_to conversions_url, notice:  "#{t(:conversion)} #{t(:was_successfully_deleted)}" }
    end
  end

  def clear
    respond_to do |format|
      format.html { redirect_to conversions_url, notice:  "#{t(:conversion)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def conversion_params
    params.require(:conversion).permit(Conversion.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['conversions', conversions_path], ["#{t(:new)} #{t(:conversion)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Sie_diff_roes', conversions_path], [@conversion.old_number]]
  end
end
