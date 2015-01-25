module Services
  class OrganizationCreator

    def initialize(organization, user)
      @user = user
      @organization = organization
    end

    def save
      @organization.organization_roles.build(name: OrganizationRole::ROLE_ADMIN,
          user_id: @user.id)
      @organization.save
    end
  end
end
