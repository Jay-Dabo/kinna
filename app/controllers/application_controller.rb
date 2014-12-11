class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Default is the always ensure the user is signed in.
  before_filter :authenticate_user!

  # Default to always check for authorization (cancan),
  # except the devise controller (sign in).
  check_authorization unless: :devise_controller?

  # i18n support using param from the url.
  before_filter :set_locale

  def set_locale
    current_locale = current_user.default_locale if current_user
    I18n.locale = locale_from_params || current_locale || I18n.default_locale
  end

  def url_options
    o = {locale: I18n.locale}
    o[:organization_slug] = current_organization.slug if current_organization
    o.merge(super)
  end

  # this is also needed becauses unknown reason.
  # without this, the locale is not present when there is no organization_slug needed for the route.
  def default_url_options(options={})
    options.merge({locale: I18n.locale})
  end

  def current_organization
    return nil unless signed_in?
    unless @current_organization
      load_organization if params[:organization_slug]
    end
    @current_organization
  end

  helper_method :current_organization


  def load_organization
    redirect_to(root_path) and return unless current_user
    @current_organization ||= Organization.find_by_slug(params[:organization_slug])
    authorize! :read, @current_organization
  end

  private

  # only allow certian locales to be passed.
  def locale_from_params
    params[:locale] if (params[:locale] && ['en', 'se'].include?(params[:locale]))
  end

  def current_ability
    @current_ability ||= Ability.new(current_user, current_organization)
  end
end
