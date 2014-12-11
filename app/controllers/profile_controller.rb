class ProfileController < ApplicationController
  authorize_resource :user
  before_filter :set_breadcrumbs
  before_filter :load_user
  before_filter :load_contact_variables, only: [:show]

  def show
  end

  def update
    user_params = safe_user_params

    # If authenticated user is updating self with new locale, change current locale.
    if (@user.id == current_user.id && user_params[:default_locale] != I18n.locale)
      params[:locale] = user_params[:default_locale]
      I18n.locale = user_params[:default_locale]
    end

    if @user.update(user_params)

      # This is needed since devise throws out the session when password is updated.
      unless user_params[:password].blank?
        sign_in 'user', current_user, bypass: true
      end

      flash[:notice] = "#{t(:your_profile)} #{t(:was_successfully_updated)}"
      redirect_to profile_path(locale: I18n.locale)
    else
      flash.now[:danger] = "#{t(:failed_to_update)} #{t(:your_profile)}."
      load_contact_variables
      render :show
    end
  end

  private

  def safe_user_params
    uparams ||= params.require(:user).permit(:name, :email, :password, :password_confirmation, :default_locale)
    if uparams[:password].blank?
      uparams.delete(:password)
      uparams.delete(:password_confirmation)
    end
    uparams
  end

  def set_breadcrumbs
    @breadcrumbs = [[t(:profile)]]
  end

  def load_user
    @user = current_user
  end

  def load_contact_variables
    unless current_organization
      @contact_relation = false
      @contact = false
      @contact_relation_form_url = false
      return
    end

    if @user.contact_relations.search_by_org(current_organization).first.nil?
      @contact_relation = @user.contact_relations.build
      @contact = @contact_relation.build_contact
      @contact_relation_form_url = contact_relations_path(parent_type: @contact_relation.parent_type,
          parent_id: @contact_relation.parent_id,
          organization_slug: current_organization.slug)
    else
      @contact_relation = @user.contact_relations.search_by_org(current_organization).first
      @contact = @user.contacts.search_by_org(current_organization).first
      @contact_relation_form_url = contact_relation_path(@contact_relation,
                                                         parent_type: 'User',
          parent_id: @user.id,
          organization_slug: current_organization.slug)
    end
  end
end
