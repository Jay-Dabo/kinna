class ReportsController < ApplicationController
  respond_to :html, :json, :pdf
  #load_and_authorize_resource :accounting_period, through: :current_organization
  #load_and_authorize_resource :verificate, through: :accounting_period
  #load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  def order_verificates_report
    @accounting_period = current_organization.accounting_periods.where('active = true').first
    @report = Report.new @accounting_period
    @accounting_periods = current_organization.accounting_periods
  end

  def verificates
    @report = Report.new params[:report][:accounting_period]
    @accounting_period = current_organization.accounting_periods.find(@report.accounting_period)
    @verificates = current_organization.verificates.where("accounting_period_id = ? AND state = 'final'", @accounting_period.id).order(:number)
    @verificates = @verificates.decorate
    respond_to do |format|
      format.pdf do
        render(pdf: 'verificates', template: 'reports/verificates.pdf.haml', layout: 'pdf')
      end
      format.html
    end
  end

  def order_ledger_report
    @accounting_period = current_organization.accounting_periods.where('active = true').first
    @report = Report.new @accounting_period
    @accounting_periods = current_organization.accounting_periods
  end

  def ledger
    @report = Report.new params[:report][:accounting_period]
    @accounting_period = current_organization.accounting_periods.find(@report.accounting_period)
    @verificate_items = VerificateItem
    .joins(:verificate, :account)
    .where("verificate_items.organization_id = ? AND verificate_items.accounting_period_id = ? AND verificates.state = 'final'", current_organization.id, @accounting_period.id)
    .select('accounts.number AS num','accounts.description AS desc', "SUM(debit) AS deb", "SUM(credit) AS cre")
    .group('accounts.number', 'accounts.description')
    .order('accounts.number')

    respond_to do |format|
      format.pdf do
        render(pdf: 'ledger', template: 'reports/ledger.pdf.haml', layout: 'pdf')
      end
      format.html
    end
  end

  def order_result_report
    @accounting_period = current_organization.accounting_periods.where('active = true').first
    @report = Report.new @accounting_period
    @accounting_periods = current_organization.accounting_periods
  end

  def result_report
    @report = Report.new params[:report][:accounting_period]
    @accounting_period = current_organization.accounting_periods.find(@report.accounting_period)
    @verificate_items = VerificateItem
    .joins(:verificate, :account => :accounting_class)
    .where("verificate_items.organization_id = ? AND verificate_items.accounting_period_id = ? AND verificates.state = 'final' AND accounting_classes.number > '2999' ", current_organization.id, @accounting_period.id)
    .select('accounting_classes.number AS cls', 'accounting_classes.name AS cls_dsc', 'accounts.number AS num','accounts.description AS desc', "SUM(debit) AS deb", "SUM(credit) AS cre")
    .group('accounting_classes.number', 'accounting_classes.name', 'accounts.number', 'accounts.description')
    .order('accounts.number')

    respond_to do |format|
      format.pdf do
        render(pdf: 'ledger', template: 'reports/result.pdf.haml', layout: 'pdf')
      end
      format.html
    end
  end

  def order_balance_report
    @accounting_period = current_organization.accounting_periods.where('active = true').first
    @report = Report.new @accounting_period
    @accounting_periods = current_organization.accounting_periods
  end

  def balance_report
    @report = Report.new params[:report][:accounting_period]
    @accounting_period = current_organization.accounting_periods.find(@report.accounting_period)



    @opening_balance_items =
    @verificate_items = Account
    .joins("INNER JOIN accounting_classes ON accounting_classes.id = accounts.accounting_class_id")
    .select("accounts.number as acc,
accounts.description as desc,
accounting_classes.number as cls,
accounting_classes.name as cls_desc,
(select sum(debit-credit) as ib from opening_balance_items where opening_balance_items.accounting_period_id = #{@accounting_period.id} and opening_balance_items.account_id = accounts.id),
(select sum(debit-credit) as ver from verificate_items where verificate_items.accounting_period_id = #{@accounting_period.id} AND verificate_items.account_id = accounts.id)
")
    .where("accounts.number < '2999'")
    .order('accounts.number')

    @verificate_itemsx = VerificateItem
    .joins(:verificate, :account => :accounting_class)
    .where("verificate_items.organization_id = ? AND verificate_items.accounting_period_id = ? AND verificates.state = 'final' AND accounting_classes.number < '2999' ", current_organization.id, @accounting_period.id)
    .select('accounting_classes.number AS cls', 'accounting_classes.name AS cls_dsc', 'accounts.number AS num','accounts.description AS desc', "SUM(debit) AS deb", "SUM(credit) AS cre")
    .group('accounting_classes.number', 'accounting_classes.name', 'accounts.number', 'accounts.description')
    .order('accounts.number')

    respond_to do |format|
      format.pdf do
        render(pdf: 'ledger', template: 'reports/balance.pdf.haml', layout: 'pdf')
      end
      format.html
    end
  end

  def vat_report
    @report = Report.new(params[:from_short_date], params[:to_short_date])
    @accounting_period = AccountingPeriod.find(params[:report][:accounting_period].to_i)
    @sale_items = VerificateItem
    .joins(:verificate, :account => :accounting_group)
    .where("verificate_items.organization_id = ? AND verificate_items.accounting_period_id = ? AND verificates.state = 'final' AND accounting_groups.number > '30' AND accounting_groups.number < '35' AND verificates.posting_date > ? AND verificates.posting_date < ? ", current_organization.id, @accounting_period.id, params[:from_short_date], params[:to_short_date])
    .select('accounts.number AS num','accounts.description AS desc', "SUM(debit) AS deb", "SUM(credit) AS cre")
    .group('accounts.number', 'accounts.description')
    .order('accounts.number')

    @verificate_items = VerificateItem
    .joins(:verificate, :account => [:accounting_class, :accounting_group])
    .where("verificate_items.organization_id = ? AND verificate_items.accounting_period_id = ? AND verificates.state = 'final' AND accounting_groups.number = '26' ", current_organization.id, @accounting_period.id)
    .select('accounting_classes.number AS cls', 'accounting_classes.name AS cls_dsc', 'accounts.number AS num','accounts.description AS desc', "SUM(debit) AS deb", "SUM(credit) AS cre")
    .group('accounting_classes.number', 'accounting_classes.name', 'accounts.number', 'accounts.description')
    .order('accounts.number')

    respond_to do |format|
      format.pdf do
        render(pdf: 'vat_report', template: 'reports/vat_report.pdf.haml', layout: 'pdf')
      end
      format.html
    end
  end

  # GET
  def index
    @breadcrumbs = [['Verificates']]
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
    if !params[:accounting_period_id] && @accounting_periods.count > 0
      params[:accounting_period_id] = @accounting_periods.first.id
    end
    @verificates = current_organization.verificates.where('accounting_period_id=?', params[:accounting_period_id]).order(:number)
    @verificates = @verificates.page(params[:page]).decorate
  end

  # GET
  def new
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
    gon.push accounting_periods: ActiveModel::ArraySerializer.new(@accounting_periods, each_serializer: AccountingPeriodSerializer)
    @templates = current_organization.templates
  end

  # GET
  def show
    @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
    gon.push accounting_periods: ActiveModel::ArraySerializer.new(@accounting_periods, each_serializer: AccountingPeriodSerializer)
  end

  # GET
  def edit
  end

  # POST
  def create
    Rails.logger.info "#{params.inspect}"
    if !params[:template].blank?
      template = current_organization.templates.find(params[:template])
      params[:verificate][:description] = template.description + params[:verificate][:description]
    end
    #@accounting_period = current_organization.accounting_periods.find(params[:accounting_period_id])
    #@verificate = @accounting_period.verificates.build verificate_params
    @verificate = Verificate.new(verificate_params)
    @verificate.organization = current_organization
    respond_to do |format|
      if @verificate.save
        format.html { redirect_to verificate_path(@verificate), notice: "#{t(:verificate)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:verificate)}"
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        gon.push accounting_periods: ActiveModel::ArraySerializer.new(@accounting_periods, each_serializer: AccountingPeriodSerializer)
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
        @accounting_periods = current_organization.accounting_periods.where('active = ?', true)
        gon.push accounting_periods: ActiveModel::ArraySerializer.new(@accounting_periods, each_serializer: AccountingPeriodSerializer)
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
    @verificate = current_organization.verificates.find(params[:id])
    authorize! :manage, @verificate
    if @verificate.state_change(params[:event])
      msg_h = { notice: t(:success) }
    else
      msg_h = { alert: t(:fail) }
    end
    redirect_to @verificate, msg_h
  end

  def add_verificate_items
    Rails.logger.info "Kolla: #{params.inspect}"
    @verificate = current_organization.verificates.find(params[:id])
    @verificate_items_creator = Services::VerificateItemsCreator.new(current_organization, current_user, @verificate, params)
    respond_to do |format|
      if @verificate_items_creator.save
        format.html { redirect_to verificates_url, notice: "#{t(:verificates_items)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:verificates_items)}"
        format.html { redirect_to verificates_url }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def new_breadcrumbs
    @breadcrumbs = [["#{t(:verificates)}", verificates_path], ["#{t(:new)} #{t(:verificate)}"]]
  end

  def show_breadcrumbs
    @verificate.number ? bc = @verificate.number : bc = '*'
    @breadcrumbs = [["#{t(:verificates)}", verificates_path], [bc]]
  end
end
