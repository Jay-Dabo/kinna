class TaxCodesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /wages
  # GET /wages.json
  def index
    @breadcrumbs = [['Tax codes']]
    @tax_codes = current_organization.tax_codes.order(:code)
    @tax_codes = @tax_codes.page(params[:page])
  end

  # GET /wages/new
  def new
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true).order('id')
  end

  # GET /wages/1
  def show
  end

  # GET /wage/1/edit
  def edit
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
  end

  # POST /wages
  # POST /wages.json
  def create
    @tax_code = TaxCode.new(tax_code_params)
    @tax_code.organization = current_organization
    respond_to do |format|
      if @tax_code.save
        format.html { redirect_to tax_codes_url, notice: 'tax code period was successfully created.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:tax_code)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @tax_code.update(tax_code_params)
        format.html { redirect_to tax_codes_url, notice: 'tax code period was successfully updated.' }
      else
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:tax_code)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @tax_code.destroy
    respond_to do |format|
      format.html { redirect_to tax_codes_url, notice: 'tax code period was successfully deleted.' }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def tax_code_params
    params.require(:tax_code).permit(TaxCode.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Tax codes', tax_codes_path], ["#{t(:new)} #{t(:tax_code)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Tax codes', tax_codes_path], [@tax_code.code]]
  end
end
