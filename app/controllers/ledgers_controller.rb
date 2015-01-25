class LedgersController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource  through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /ledgers
  # GET /ledgers.json
  def index
    @breadcrumbs = [['Ledger', ledgers_path]]
    @ledgers = current_organization.ledgers.page(params[:page])
  end

  # GET /ledgers/new
  def new
    @ledger_periods = current_organization.ledger_periods
  end

  # GET /ledgers/1
  def show

  end

  # GET /ledger/1/edit
  def edit
    @ledger_periods = current_organization.ledger_periods
  end

  # POST /ledgers
  # POST /ledgers.json
  def create
    @ledger = ledger.new(ledger_params)
    @ledger.organization = current_organization
    respond_to do |format|
      if @ledger.save
        format.html { redirect_to ledger_period_ledgers_path, notice: "#{t(:ledger)} #{t(:was_successfully_created)}" }
      else
        @ledger_periods = current_organization.ledger_periods
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:ledger)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @ledger.update(ledger_params)
        format.html { redirect_to ledger_period_ledgers_path, notice: "#{t(:ledger)} #{t(:was_successfully_updated)}" }
      else
        @ledger_periods = current_organization.ledger_periods
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:ledger)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @ledger.destroy
    respond_to do |format|
      format.html { redirect_to ledger_period_ledgers_path, notice: "#{t(:ledger)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def ledger_params
    params.require(:ledger).permit(Ledger.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [['ledger periods', ledger_periods_path], [@ledger.ledger_period.name, ledger_period_path(@ledger.ledger_period_id)],
                    ['ledgers', ledger_period_ledgers_path(@ledger.ledger_period_id)],
                    ['New ledger']]
  end

  def show_breadcrumbs
    @breadcrumbs = [['ledger periods', ledger_periods_path], [@ledger.ledger_period.name, ledger_period_path(@ledger.ledger_period_id)],
                    ['ledgers', ledger_period_ledgers_path(@ledger.ledger_period_id)],
                    [@ledger.employee.name]]
  end
end
