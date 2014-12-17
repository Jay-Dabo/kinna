module Admin
  class ApplicationController < ::ApplicationController
    before_filter :ensure_superadmin

    def ensure_superadmin
      unless current_user.superadmin?
        redirect_to root_path, error: "403"
      end
    end
  end
end
