module Services
  class Invite
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    def persisted?;
      false;
    end

    attr_accessor :organization, :invite_params, :errors, :email

    validates :email, presence: true

    def initialize(organization, invite_params = {})
      @errors = ActiveModel::Errors.new(self)
      @organization = organization
      @invite_params = invite_params
    end

    def add_or_create
      u = User.find_by_email invite_params[:email]
      u = create_new_user unless u

      unless u
        Rails.logger.error "unable to invite#add_or_create without user, params; #{invite_params.inspect}"
        return false
      end
      if (u.organization_roles.where(organization_id: @organization.id).count > 0
        )
        errors.add(:email, I18n.t(:already_exists))
        return false
      end

      contact = organization.contacts.find_by_email u.email
      if contact
        @contact_relation = u.build_contact_relation
        @contact_relation.organization = @organization
        @contact_relation.contact = contact
        @contact_relation.save
      end

      user_roles = Services::UserRoles.new(u, organization, {OrganizationRole::ROLE_STAFF => "1"}.with_indifferent_access)
      user_roles.sync

    end

    def create_new_user
      new_pass = rand(36**8).to_s(36) # generates 8 random char a-z0-9
      new_user = User.new(email: invite_params[:email],
          password: new_pass,
          password_confirmation: new_pass)
      unless new_user.save
        new_user.errors.each do |error|
          Rails.logger.info "adding error: #{error}   #{errors.class.name}"
          errors.add(error)
        end
        return false
      end
      new_user
    end
  end
end
