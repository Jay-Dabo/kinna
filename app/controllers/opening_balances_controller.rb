class OpeningBalancesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET
  def index
    @breadcrumbs = [['Opening balances']]
    @opening_balances = current_organization.opening_balances
    @opening_balances = @opening_balances.page(params[:page]).decorate
  end

  # GET
  def new
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
    gon.push accounting_periods: ActiveModel::ArraySerializer.new(@accounting_periods, each_serializer: AccountingPeriodSerializer)
  end

  # GET
  def show
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
    gon.push accounting_periods: ActiveModel::ArraySerializer.new(@accounting_periods, each_serializer: AccountingPeriodSerializer)
    @previous_accounting_period = @opening_balance.accounting_period.previous_accounting_period
  end

  # GET
  def edit
  end

  # POST
  def create
    @opening_balance = OpeningBalance.new(opening_balance_params)
    @opening_balance.organization = current_organization
    respond_to do |format|
      if @opening_balance.save
        format.html { redirect_to opening_balance_path(@opening_balance), notice: "#{t(:opening_balance)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:opening_balance)}"
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        gon.push accounting_periods: ActiveModel::ArraySerializer.new(@accounting_periods, each_serializer: AccountingPeriodSerializer)
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT
  def update
    respond_to do |format|
      if @opening_balance.update(opening_balance_params)
        format.html { redirect_to opening_balances_path, notice: "#{t(:opening_balance)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:opening_balance)}"
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        gon.push accounting_periods: ActiveModel::ArraySerializer.new(@accounting_periods, each_serializer: AccountingPeriodSerializer)
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE
  def destroy
    @opening_balance.destroy
    respond_to do |format|
      format.html { redirect_to opening_balances_path, notice:  "#{t(:opening_balance)} #{t(:was_successfully_deleted)}" }
    end
  end

  def state_change
    authorize! :manage, @verificate
    if @opening_balance.state_change(params[:event], params[:state_change_at])
      msg_h = { notice: t(:success) }
    else
      msg_h = { alert: t(:fail) }
    end
    redirect_to opening_balances_url, msg_h
  end

  def create_from_ub
    @opening_balance = current_organization.opening_balances.find(params[:opening_balance_id])
    @accounting_period = @opening_balance.accounting_period
    @from = @accounting_period.previous_accounting_period
    respond_to do |format|
      @opening_balance_creator = Services::OpeningBalanceCreator.new(current_organization, current_user, @accounting_period, @opening_balance)
      if @opening_balance_creator.add_from_ub(@from.closing_balance)
        format.html { redirect_to opening_balances_path, notice:  "#{t(:opening_balance)} #{t(:was_successfully_deleted)}" }
      else
        format.html { redirect_to opening_balances_path, notice:  "#{t(:opening_balance)} #{t(:faild_to_update)}" }
      end

    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def opening_balance_params
    params.require(:opening_balance).permit(OpeningBalance.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:opening_balances)}", opening_balances_path], ["#{t(:new)} #{t(:opening_balance)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [["#{t(:opening_balances)}", opening_balances_path], [@opening_balance.description]]
  end
end
