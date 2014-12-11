module Admin
  class UsersController < Admin::ApplicationController
    load_and_authorize_resource :organization
    load_and_authorize_resource :user, through : :organization
    before_filter :set_breadcrumbs
    before_filter :new_breadcrumbs, only : [:new, :create]
    before_filter :show_breadcrumbs, only : [:show, :update_role]

    def new
    end

    def show
      @user_roles = Services::UserRoles.new(@user, @organization)
    end

    # Create a new user and add access to the current organization as 'staff'
    def create
      @user = User.new(user_params)
      #@user.organization_roles.build(organization_id: @organization.id, name: OrganizationRole::ROLE_STAFF)
      new_role = @user.organization_roles.build(name : OrganizationRole::ROLE_STAFF)
      new_role.organization_id = @organization.id

      @user.default_organization = @organization
      if @user.save
        redirect_to admin_organization_path(@organization),
                    notice : "#{t(:new)} #{t(:user)} #{t(:was_successfully_created)}"
      else
        render :new
      end
    end

    def update_roles
      @user_roles = Services::UserRoles.new(@user, @organization, role_params)
      if @user_roles.sync
        flash.now[:notice] = "#{t(:user)} #{t(:roles)} #{t(:was_successfully_updated)}"
      else
        flash.now[:danger] = "#{t(:failed_to_update)} #{t(:roles)} "+
            "#{t(:user)}(#{@user.email}) #{t(:organization)}(#{@organization.name})"
      end
      render :show
    end

    private

    def user_params
      params.require(:user).permit(User.accessible_attributes.to_a)
    end

    def role_params
      params.require(:services_user_roles).permit(OrganizationRole::ROLES)
    end

    def set_breadcrumbs
      @breadcrumbs = [
          [t(:organizations), admin_organizations_path],
          [@organization.name, admin_organization_path(@organization)]
      ]
    end

    def new_breadcrumbs
      @breadcrumbs << ["#{t(:new)} #{t(:user)}"]
    end

    def show_breadcrumbs
      @breadcrumbs << [@user.name]
    end
  end
end
