class UsersController < ApplicationController
  before_filter :load_user, only: [:show, :update_roles]
  before_filter :show_breadcrumbs, only: [:show, :update]
  before_filter :new_breadcrumbs, only: [:new, :create]

  # GET /users
  # GET /users.json
  def index
    @users = current_organization.users.order(:name).page(params[:page])
    @breadcrumbs = [['Users']]
    @users.each do |u|
      authorize! :read, u
    end
    @invite = Services::Invite.new(current_organization)
  end

  # GET /users/1
  # GET /users/1.json
  def show
    authorize! :read, @user

    @breadcrumbs = [['Users', users_path], [@user.email]]
    if @user.contact_relations.search_by_org(current_organization).first.nil?
      @contact_relation = @user.contact_relations.build
      @contact = @contact_relation.build_contact
      @contact_relation_form_url = contact_relations_path(parent_type: @contact_relation.parent_type, parent_id: @contact_relation.parent_id)
    else
      @contact_relation = @user.contact_relations.search_by_org(current_organization).first
      @contact = @user.contacts.search_by_org(current_organization).first
      @contact_relation_form_url = contact_relation_path(@contact_relation)
    end
    @user_roles = Services::UserRoles.new(@user, current_organization)
  end

  # GET /users/new
  def new
    @invite = Services::Invite.new(current_organization)
    authorize! :create, @invite
  end

  # POST /users
  def create
    @invite = Services::Invite.new(current_organization, invite_params)
    authorize! :create, @invite

    if @invite.add_or_create
      flash[:info] = "#{t(:invite)} #{t(:was_successfully_created)}"
      redirect_to(users_path)
    else
      flash.now[:danger] = "#{t(:failed_to_create)} #{t(:invite)}"
      render :new
    end
  end

  def update_roles
    @user_roles = Services::UserRoles.new(@user, current_organization, role_params)
    authorize! :manage, @user_roles

    logger.info "will update roles for #{@user.name} with :#{role_params.inspect}"
    if @user_roles.sync
      flash[:notice] = "#{t(:user)} #{t(:roles)} #{t(:was_successfully_updated)}"
    else
      flash[:danger] = "#{t(:failed_to_update)} #{t(:roles)} "+
          "#{t(:user)}(#{@user.email}) #{t(:organization)}(#{current_organization.name})"
    end
    # Redirect to user list if the user have been removed from the organization.
    if @user.organization_roles.where(organization_id:
      current_organization.id).count > 0
      redirect_to user_path(@user)
    else
      redirect_to users_path
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def load_user
    @user = User.find(params[:id])
  end

  def invite_params
    params.require(:services_invite).permit(:email)
  end

  def role_params
    rprms = params.require(:services_user_roles).permit(OrganizationRole::ROLES)
  end

  def show_breadcrumbs
    @breadcrumbs = [[t(:users), users_path], [@user.name]]
  end

  def new_breadcrumbs
    @breadcrumbs = [[t(:users), users_path], ["#{t(:new)} #{t(:user)}"]]
  end
end
