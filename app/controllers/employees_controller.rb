class EmployeesController < ApplicationController
  respond_to :html, :json
  load_and_authorize_resource through: :current_organization

  before_filter :new_breadcrumbs, only: [:new, :create]
  before_filter :show_breadcrumbs, only: [:edit, :show, :update]

  # GET /vats
  # GET /vats.json
  def index
    @breadcrumbs = [["#{t(:employees)}"]]
    init
  end

  # GET /vats/new
  def new
  end

  # GET /vats/1
  def show
  end

  # GET /vat/1/edit
  def edit
  end

  # POST /vats
  # POST /vats.json
  def create
    @employee = Employee.new(employee_params)
    @employee.organization = current_organization
    respond_to do |format|
      if @employee.save
        format.html { redirect_to employees_url, notice: "#{t(:employee)} #{t(:was_successfully_created)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_create)} #{t(:employee)}"
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to employees_url, notice: "#{t(:employee)} #{t(:was_successfully_updated)}" }
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:employee)}"
        format.html { render action: 'show' }
      end
    end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @employee.destroy
    respond_to do |format|
      format.html { redirect_to employees_url, notice: "#{t(:employee)} #{t(:was_successfully_deleted)}" }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def employee_params
    params.require(:employee).permit(Employee.accessible_attributes.to_a)
  end

  def new_breadcrumbs
    @breadcrumbs = [["#{t(:employee)}", employees_path], ["#{t(:new)} #{t(:employee)}"]]
  end

  def show_breadcrumbs
    @breadcrumbs = [["#{t(:employee)}", employees_path], [@employee.name]]
  end

  def init
    @employees = current_organization.employees.order(:name)
    @employees = @employees.page(params[:page]).decorate
  end
end
