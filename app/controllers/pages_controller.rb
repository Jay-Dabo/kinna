class PagesController < ApplicationController
  # Everybody can se pages.
  # Skip the cancan thingie and the authenticate_user! filter
  skip_authorization_check
  before_filter :authenticate_user!, except: [:start, :about, :formats]
  before_filter :redirect_authenticated_user

  # Only non logged in users should be able to see the start page.
  def start
    @breadcrumbs = [['/']]
  end

  def about
    @breadcrumbs = [[t(:about)]]
  end

  def formats
  end

  private

  def redirect_authenticated_user
    if user_signed_in?
      if current_user.default_organization
        redirect_to dashboard_path(organization_slug: current_user.default_organization.slug)
      else
        redirect_to organization_selector_path
      end
    end
  end
end
