class ImportBankFileRowsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :import_bank_file, through: :current_organization
  load_and_authorize_resource :import_bank_file_row, through: :import_bank_file

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [['import_bank_file_row']]
  end

  # GET
  def new
    @accounting_groups = current_organization.accounting_plan.accounting_groups
    gon.push accounting_groups: ActiveModel::ArraySerializer.new(@accounting_groups, each_serializer: AccountingGroupSerializer)
  end

  # GET
  def show
    ver_id = 0
    @verificates = current_organization.verificates.where('state = ?', 'preliminary')
    @verificates.each do |verificate|
      if verificate.bank_amount == @import_bank_file_row.amount
        verificate.posting_date = @import_bank_file_row.posting_date
        verificate.save
        ver_id = verificate.id
      end
    end
    if ver_id > 0
      redirect_to verificate_path(ver_id)
    else
      @verificate_creator = Services::VerificateCreator.new(current_organization, current_user, @import_bank_file_row)
      @verificate_creator.save_bank_file_row
      redirect_to verificate_path(@verificate_creator.verificate_id)
    end

  end

  # GET
  def edit
  end

  # POST
  def create
    @template = current_organization.templates.find(params[:template_id])
    @import_bank_file_row = @template.import_bank_file_rows.build import_bank_file_row_params
    @import_bank_file_row.organization = current_organization
    respond_to do |format|
      if @import_bank_file_row.save
        format.html { redirect_to template_path(@template), notice: "#{t(:import_bank_file_row)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:import_bank_file_row)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @import_bank_file_row.update(import_bank_file_row_params)
        format.html { redirect_to template_path(@template), notice: "#{t(:import_bank_file_row)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:import_bank_file_row)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @import_bank_file_row.destroy
    respond_to do |format|
      format.html { redirect_to template_path(@template), notice:  "#{t(:import_bank_file_row)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def import_bank_file_row_params
    params.require(:import_bank_file_row).permit(TemplateItem.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:templates), templates_path], [@template.name, template_path(@template)], ["#{t(:new)} #{t(:import_bank_file_row)}"]]
  end

  def show_breadcrumbs
    # @breadcrumbs = [[t(:templates), templates_path], [@template.name, template_plan_path(@template)], [@import_bank_file_row.description]]
  end
end
