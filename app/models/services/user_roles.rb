module Services
  class UserRoles
    extend ActiveModel::Naming
    include ActiveModel::Conversion

    def persisted?;
      false;
    end

    attr_accessor :user, :organization, :organization_roles, :current_roles

    def initialize(user, organization, role_params = {})
      @user = user
      @organization = organization
      @role_params = role_params

      @organization_roles = @user.organization_roles.where(organization_id: organization.id)
      @current_roles = @organization_roles.map { |role| role.name }
    end

    OrganizationRole::ROLES.each do |role_name|
      define_method(role_name) do
        current_roles.include? role_name
      end
    end

    # return true unless exception was raised
    def sync
      @role_params.each do |role, value|
        if value.eql?("1") && !@current_roles.include?(role)
          org_role = @user.organization_roles.build(name: role)
          org_role.organization_id = @organization.id
          org_role.save!

        elsif !value.eql?("1") && @current_roles.include?(role)
          role = @user.organization_roles.where(organization_id: @organization.id).where(name: role)
          role.map { |r| r.destroy } # There should only be one but...
        end
      end
      true
    rescue RuntimeError => e
      Rails.logger.error "exception: #{e}"
      Rails.logger.error "failed to update user role: #{self.inspect}"
      false
    end
  end
end
