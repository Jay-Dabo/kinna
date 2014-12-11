module Admin
  class DashboardController < Admin::ApplicationController
    def index
      @organizations = Organization.page(params[:page] || 1)
      authorize! :manage, @organizations
    end
  end
end
