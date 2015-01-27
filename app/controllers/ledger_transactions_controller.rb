class LedgerTransactionsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource  through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /ledger_transations
  # GET /ledger_transation_transations.json
  def index
    @ledger = current_organization.ledgers.find(params[:ledger_id])
    @account = current_organization.accounts.find(params[:account_id])
    name = @account.number.to_s + ' ' + @account.description
    @breadcrumbs = [[t(:ledgers), ledgers_path], [@ledger.name, ledger_ledger_accounts_path(@ledger.id)], [name]]
    @ledger_transactions = current_organization.ledger_transactions.where('ledger_id = ? AND account_id = ? ', params[:ledger_id], params[:account_id]).page(params[:page]).decorate
  end

  # GET /ledger_transation_transations/new
  def new
  end

  # GET /ledger_transations/1
  def show
  end

  # GET /ledger_transation/1/edit
  def edit
  end

  # POST /ledger_transations
  # POST /ledger_transations.json
  def create
    @ledger_transation = LeddgerTransation.new(ledger_transation_params)
    @ledger_transation.organization = current_organization
    respond_to do |format|
      if @ledger_transation.save
        format.html { redirect_to ledger_transations_path, notice: "#{t(:ledger_transation)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:ledger_transation)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @ledger_transation.update(ledger_transation_params)
        format.html { redirect_to ledger_transations_path, notice: "#{t(:ledger_transation)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:ledger_transation)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @ledger_transation.destroy
    respond_to do |format|
      format.html { redirect_to ledger_transations_path, notice: "#{t(:ledger_transation)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def ledger_transation_params
    params.require(:ledger_transation).permit(ledger_transation.accessible_attributes.to_a)
  end

  def new_breadcrumbs
  end

  def show_breadcrumbs
  end
end
