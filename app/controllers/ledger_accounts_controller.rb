class LedgerAccountsController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource :ledger, through: :current_organization
  load_and_authorize_resource :ledger_account, through: :ledger

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [[t(:ledgers), ledgers_path], [@ledger.name]]
    @ledger_accounts = @ledger_accounts.decorate.sort_by { |ledger_account| ledger_account.account_number}
    @ledger_accounts = Kaminari.paginate_array(@ledger_accounts).page(params[:page])
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
    @ledger = current_organization.ledgers.find(params[:ledger_id])
    @ledger_account = @ledger.ledger_accounts.build ledger_account_params
    @ledger_account.organization = current_organization
    respond_to do |format|
      if @ledger_account.save
        format.html { redirect_to ledger_accounts_path, notice: "#{t(:ledger_account)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:ledger_account)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @ledger_account.update(ledger_account_params)
        format.html { redirect_to ledger_accounts_path, notice: "#{t(:ledger_account)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:ledger_account)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @ledger_account.destroy
    respond_to do |format|
      format.html { redirect_to ledger_account_path, notice:  "#{t(:ledger_account)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def ledger_account_params
    params.require(:ledger_account).permit(LedgerAccount.accessible_attributes.to_a)
  end

  def new_breadcrumbs
  end

  def show_breadcrumbs
  end
end
