# frozen_string_literal: true

constraints(::Constraints::ProjectUrlConstrainer.new) do
  scope(path: '*namespace_id',
        as: :namespace,
        namespace_id: Gitlab::PathRegex.full_namespace_route_regex) do
    scope(path: ':project_id',
          constraints: { project_id: Gitlab::PathRegex.project_route_regex },
          module: :projects,
          as: :project) do
      # Begin of the /-/ scope.
      # Use this scope for all new project routes.
      scope '-' do
        resources :packages, only: [:index, :show, :destroy], module: :packages
        resources :package_files, only: [], module: :packages do
          member do
            get :download
          end
        end

        resources :jobs, only: [], constraints: { id: /\d+/ } do
          member do
            get '/proxy.ws/authorize', to: 'jobs#proxy_websocket_authorize', format: false
            get :proxy
          end
        end

        resources :feature_flags
        resource :feature_flags_client, only: [] do
          post :reset_token
        end

        resources :autocomplete_sources, only: [] do
          collection do
            get 'epics'
          end
        end

        namespace :settings do
          resource :operations, only: [] do
            member do
              post :reset_alerting_token
            end
          end

          resource :slack, only: [:destroy, :edit, :update] do
            get :slack_auth
          end
        end

        # DEPRECATED: Remove this redirection in GitLab 13.0.
        # This redirection supports old (pre-12.9) routes to Design Management raw images.
        # https://gitlab.com/gitlab-org/gitlab/issues/208256
        get '/designs/:id(/*ref)',
          as: :design,
          contraints: { id: /\d+/, ref: Gitlab::PathRegex.git_reference_regex },
          to: redirect { |params|
            namespace_id, project_id, id, ref = params.values_at(:namespace_id, :project_id, :id, :ref)
            # The :ref route segment is optional in both this route, and the route
            # we redirect to (where it is called :sha).
            ref_path = "/#{ref}" if ref
            "#{namespace_id}/#{project_id}/-/design_management/designs/#{id}#{ref_path}/raw_image"
          }

        namespace :design_management do
          namespace :designs, path: 'designs/:design_id(/:sha)', constraints: -> (params) { params[:sha].nil? || Gitlab::Git.commit_id?(params[:sha]) } do
            resource :raw_image, only: :show
            resources :resized_image, only: :show, constraints: -> (params) { DesignManagement::DESIGN_IMAGE_SIZES.include?(params[:id]) }
          end
        end

        resources :subscriptions, only: [:create, :destroy]

        resource :threat_monitoring, only: [:show], controller: :threat_monitoring

        resources :protected_environments, only: [:create, :update, :destroy], constraints: { id: /\d+/ } do
          collection do
            get 'search'
          end
        end

        resources :audit_events, only: [:index]

        namespace :security do
          resources :waf_anomalies, only: [] do
            get :summary, on: :collection
          end

          resource :network_policies, only: [] do
            get :summary, on: :collection
          end

          resources :dashboard, only: [:index], controller: :dashboard
          resource :configuration, only: [:show], controller: :configuration
          resource :discover, only: [:show], controller: :discover

          resources :vulnerability_findings, only: [:index] do
            collection do
              get :summary
            end
          end

          resources :vulnerabilities, only: [:show, :index]
        end

        namespace :analytics do
          resources :code_reviews, only: [:index]
          resource :issues_analytics, only: [:show]
        end

        resources :approvers, only: :destroy
        resources :approver_groups, only: :destroy
        resources :push_rules, constraints: { id: /\d+/ }, only: [:update]
        resources :vulnerability_feedback, only: [:index, :create, :update, :destroy], constraints: { id: /\d+/ }
        resources :dependencies, only: [:index]
        resources :licenses, only: [:index, :create, :update]
      end
      # End of the /-/ scope.

      # All new routes should go under /-/ scope.
      # Look for scope '-' at the top of the file.
      # rubocop: disable Cop/PutProjectRoutesUnderScope

      resources :path_locks, only: [:index, :destroy] do
        collection do
          post :toggle
        end
      end

      namespace :prometheus do
        resources :alerts, constraints: { id: /\d+/ }, only: [:index, :create, :show, :update, :destroy] do
          post :notify, on: :collection
          member do
            get :metrics_dashboard
          end
        end

        resources :metrics, constraints: { id: %r{[^\/]+} }, only: [] do
          post :validate_query, on: :collection
        end
      end

      resource :tracing, only: [:show]

      resources :web_ide_terminals, path: :ide_terminals, only: [:create, :show], constraints: { id: /\d+/, format: :json } do
        member do
          post :cancel
          post :retry
        end

        collection do
          post :check_config
        end
      end

      get '/service_desk' => 'service_desk#show', as: :service_desk
      put '/service_desk' => 'service_desk#update', as: :service_desk_refresh

      post '/restore' => '/projects#restore', as: :restore

      resources :pipelines, only: [] do
        member do
          get :security
          get :licenses
          get :codequality_report
        end
      end

      resource :insights, only: [:show], trailing_slash: true do
        collection do
          post :query
        end
      end
      # All new routes should go under /-/ scope.
      # Look for scope '-' at the top of the file.
      # rubocop: enable Cop/PutProjectRoutesUnderScope
    end
  end
end

scope path: '(/-/jira)', constraints: ::Constraints::JiraEncodedUrlConstrainer.new, as: :jira do
  scope path: '*namespace_id/:project_id',
        namespace_id: Gitlab::Jira::Dvcs::ENCODED_ROUTE_REGEX,
        project_id: Gitlab::Jira::Dvcs::ENCODED_ROUTE_REGEX do
    get '/', to: redirect { |params, req|
      ::Gitlab::Jira::Dvcs.restore_full_path(
        namespace: params[:namespace_id],
        project: params[:project_id]
      )
    }

    get 'commit/:id', constraints: { id: /\h{7,40}/ }, to: redirect { |params, req|
      project_full_path = ::Gitlab::Jira::Dvcs.restore_full_path(
        namespace: params[:namespace_id],
        project: params[:project_id]
      )

      "/#{project_full_path}/commit/#{params[:id]}"
    }

    get 'tree/*id', as: nil, to: redirect { |params, req|
      project_full_path = ::Gitlab::Jira::Dvcs.restore_full_path(
        namespace: params[:namespace_id],
        project: params[:project_id]
      )

      "/#{project_full_path}/-/tree/#{params[:id]}"
    }
  end
end
