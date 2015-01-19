class SieDiffRowsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /sie_diff_rows
  # GET /sie_diff_rows.json
  def index
    @breadcrumbs = [['Result units']]
    @sie_diff_rows = current_organization.sie_diff_rows.order(:old_number)
    @sie_diff_rows = @sie_diff_rows.page(params[:page])
  end

  # GET /sie_diff_rows/new
  def new
  end

  # GET /sie_diff_rows/1
  def show
  end

  # GET /sie_diff_row/1/edit
  def edit
  end

  # POST /sie_diff_rows
  # POST /sie_diff_rows.json
  def create
    @sie_diff_row = SieDiffRow.new(sie_diff_row_params)
    @sie_diff_row.organization = current_organization
    respond_to do |format|
      if @sie_diff_row.save
        format.html { redirect_to sie_diff_rows_url, notice: "#{t(:sie_diff_row)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:sie_diff_row)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /sie_diff_rows/1
  # PATCH/PUT /sie_diff_rows/1.json
  def update
    respond_to do |format|
      if @sie_diff_row.update(sie_diff_row_params)
        format.html { redirect_to sie_diff_rows_url, notice:  "#{t(:sie_diff_row)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:sie_diff_row)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /sie_diff_rows/1
  # DELETE /sie_diff_rows/1.json
  def destroy
    @sie_diff_row.destroy
    respond_to do |format|
      format.html { redirect_to sie_diff_rows_url, notice:  "#{t(:sie_diff_row)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def sie_diff_row_params
    params.require(:sie_diff_row).permit(SieDiffRow.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['Sie_diff_rows', sie_diff_rows_path], ["#{t(:new)} #{t(:sie_diff_row)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [['Sie_diff_roes', sie_diff_rows_path], [@sie_diff_row.old_number]]
  end
end
