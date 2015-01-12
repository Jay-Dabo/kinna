require 'resque/server'
Rails.application.routes.draw do
  get 'profile', to: 'profile#show'
  patch 'profile', to: 'profile#update'

  root 'pages#start'
  devise_for :users, controllers: {sessions: 'user_sessions'}
  [:about, :start, :formats, :test].each do |p|
    get "/#{p}", to: "pages##{p}"
  end

  namespace :admin do
    resources :organizations
    resources :users do
      member do
        patch 'update_roles', as: :update_roles
      end
    end
    get 'dashboard', to: 'dashboard#index'
    constraints lambda { |request| request.env['warden'].authenticate? && request.env['warden'].user.superadmin? } do
      mount Resque::Server.new, at: "resque"
    end
  end

  get "organization_selector", to: "dashboard#organization_selector"
  get ':organization_slug', to: 'organizations#show', as: 'organization'
  patch ':organization_slug', to: 'organizations#update'

  scope ':organization_slug' do
    get "dashboard", to: "dashboard#index"

    resources :accounting_periods do
      member do
        post 'import_sie', as: :import_sie
      end
    end

    post 'accounting_plan_import', to: 'accounting_plans#import', as: 'accounting_plan_import'
    resources :accounting_plans do
      resources :accounting_groups
      resources :accounting_classes
      resources :accounts
    end

    resources :closing_balances do
      resources :closing_balance_items
    end

    resources :contact_relations
    resources :contacts

    resources :employees

    resources :opening_balances do
      resources :opening_balance_items
    end

    get 'reports/order_verificates_report'
    get 'reports/order_ledger_report'
    get 'reports/order_result_report'
    get 'reports/order_balance_report'
    post 'reports/verificates'
    post 'reports/ledger'
    post 'reports/result_report'
    post 'reports/balance_report'

    resources :tax_codes

    resources :templates do
      resources :template_items
    end

    resources :users do
      member do
        patch :update_roles, as: :update_roles
      end
    end

    resources :vat_periods do
      resources :vat_reports
      member do
        post 'create_verificate', as: :create_verificate
        post 'create_vat_report', as: :create_vat_report
      end
    end

    resources :verificates do
      resources :verificate_items
      member do
        post 'state_change', as: :state_change
        post 'add_verificate_items', as: :add_verificate_items
      end
    end

    resources :wage_periods do
      resources :wages
      resources :wage_reports
      member do
        post 'create_wage', as: :create_wage
        post 'create_wage_verificate', as: :create_wage_verificate
        post 'create_wage_report', as: :create_wage_report
        post 'create_report_verificate', as: :create_report_verificate
      end
    end

  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
