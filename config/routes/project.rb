# frozen_string_literal: true

constraints(::Constraints::ProjectUrlConstrainer.new) do
  # If the route has a wildcard segment, the segment has a regex constraint,
  # the segment is potentially followed by _another_ wildcard segment, and
  # the `format` option is not set to false, we need to specify that
  # regex constraint _outside_ of `constraints: {}`.
  #
  # Otherwise, Rails will overwrite the constraint with `/.+?/`,
  # which breaks some of our wildcard routes like `/blob/*id`
  # and `/tree/*id` that depend on the negative lookahead inside
  # `Gitlab::PathRegex.full_namespace_route_regex`, which helps the router
  # determine whether a certain path segment is part of `*namespace_id`,
  # `:project_id`, or `*id`.
  #
  # See https://github.com/rails/rails/blob/v4.2.8/actionpack/lib/action_dispatch/routing/mapper.rb#L155
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
        get 'archive/*id', constraints: { format: Gitlab::PathRegex.archive_formats_regex, id: /.+?/ }, to: 'repositories#archive', as: 'archive'

        resources :artifacts, only: [:index, :destroy]

        resources :jobs, only: [:index, :show], constraints: { id: /\d+/ } do
          collection do
            resources :artifacts, only: [] do
              collection do
                get :latest_succeeded,
                  path: '*ref_name_and_path',
                  format: false
              end
            end
          end

          member do
            get :status
            post :cancel
            post :unschedule
            post :retry
            post :play
            post :erase
            get :trace, defaults: { format: 'json' }
            get :raw
            get :terminal
            get :proxy

            # These routes are also defined in gitlab-workhorse. Make sure to update accordingly.
            get '/terminal.ws/authorize', to: 'jobs#terminal_websocket_authorize', format: false
            get '/proxy.ws/authorize', to: 'jobs#proxy_websocket_authorize', format: false
          end

          resource :artifacts, only: [] do
            get :download
            get :browse, path: 'browse(/*path)', format: false
            get :file, path: 'file/*path', format: false
            get :raw, path: 'raw/*path', format: false
            post :keep
          end
        end

        namespace :ci do
          resource :lint, only: [:show, :create]
          resources :daily_build_group_report_results, only: [:index], constraints: { format: /(csv|json)/ }
        end

        namespace :settings do
          resource :ci_cd, only: [:show, :update], controller: 'ci_cd' do
            post :reset_cache
            put :reset_registration_token
            post :create_deploy_token, path: 'deploy_token/create', to: 'repository#create_deploy_token'
          end

          resource :operations, only: [:show, :update] do
            member do
              post :reset_alerting_token
            end
          end

          resource :integrations, only: [:show]

          resource :repository, only: [:show], controller: :repository do
            # TODO: Removed this "create_deploy_token" route after change was made in app/helpers/ci_variables_helper.rb:14
            # See MR comment for more detail: https://gitlab.com/gitlab-org/gitlab/-/merge_requests/27059#note_311585356
            post :create_deploy_token, path: 'deploy_token/create'
            post :cleanup
          end

          resources :access_tokens, only: [:index, :create] do
            member do
              put :revoke
            end
          end
        end

        resources :autocomplete_sources, only: [] do
          collection do
            get 'members'
            get 'issues'
            get 'merge_requests'
            get 'labels'
            get 'milestones'
            get 'commands'
            get 'snippets'
          end
        end

        resources :project_members, except: [:show, :new, :edit], constraints: { id: %r{[a-zA-Z./0-9_\-#%+]+} }, concerns: :access_requestable do
          collection do
            delete :leave

            # Used for import team
            # from another project
            get :import
            post :apply_import
          end

          member do
            post :resend_invite
          end
        end

        resources :deploy_keys, constraints: { id: /\d+/ }, only: [:index, :new, :create, :edit, :update] do
          member do
            put :enable
            put :disable
          end
        end

        resources :deploy_tokens, constraints: { id: /\d+/ }, only: [] do
          member do
            put :revoke
          end
        end

        resources :milestones, constraints: { id: /\d+/ } do
          member do
            post :promote
            put :sort_issues
            put :sort_merge_requests
            get :merge_requests
            get :participants
            get :labels
          end
        end

        resources :labels, except: [:show], constraints: { id: /\d+/ } do
          collection do
            post :generate
            post :set_priorities
          end

          member do
            post :promote
            post :toggle_subscription
            delete :remove_priority
          end
        end

        resources :services, constraints: { id: %r{[^/]+} }, only: [:edit, :update] do
          member do
            put :test
          end

          resources :hook_logs, only: [:show], controller: :service_hook_logs do
            member do
              post :retry
            end
          end
        end

        resources :boards, only: [:index, :show, :create, :update, :destroy], constraints: { id: /\d+/ } do
          collection do
            get :recent
          end
        end

        resources :releases, only: [:index, :show, :edit], param: :tag, constraints: { tag: %r{[^/]+} } do
          member do
            get :downloads, path: 'downloads/*filepath', format: false
            scope module: :releases do
              resources :evidences, only: [:show]
            end
          end
        end

        resources :logs, only: [:index] do
          collection do
            get :k8s
            get :elasticsearch
          end
        end

        resources :starrers, only: [:index]
        resources :forks, only: [:index, :new, :create]
        resources :group_links, only: [:create, :update, :destroy], constraints: { id: /\d+/ }

        resource :import, only: [:new, :create, :show]
        resource :avatar, only: [:show, :destroy]

        scope :grafana, as: :grafana_api do
          get 'proxy/:datasource_id/*proxy_path', to: 'grafana_api#proxy'
          get :metrics_dashboard, to: 'grafana_api#metrics_dashboard'
        end

        resource :mattermost, only: [:new, :create]
        resource :variables, only: [:show, :update]
        resources :triggers, only: [:index, :create, :edit, :update, :destroy]

        resource :mirror, only: [:show, :update] do
          member do
            get :ssh_host_keys, constraints: { format: :json }
            post :update_now
          end
        end

        resource :cycle_analytics, only: :show, path: 'value_stream_analytics'
        scope module: :cycle_analytics, as: 'cycle_analytics', path: 'value_stream_analytics' do
          scope :events, controller: 'events' do
            get :issue
            get :plan
            get :code
            get :test
            get :review
            get :staging
            get :production
          end
        end
        get '/cycle_analytics', to: redirect('%{namespace_id}/%{project_id}/-/value_stream_analytics')

        concerns :clusterable

        namespace :serverless do
          scope :functions do
            get '/:environment_id/:id', to: 'functions#show'
            get '/:environment_id/:id/metrics', to: 'functions#metrics', as: :metrics
          end

          resources :functions, only: [:index]
        end

        resources :environments, except: [:destroy] do
          member do
            post :stop
            post :cancel_auto_stop
            get :terminal
            get :metrics
            get :additional_metrics
            get :metrics_dashboard

            # This route is also defined in gitlab-workhorse. Make sure to update accordingly.
            get '/terminal.ws/authorize', to: 'environments#terminal_websocket_authorize', format: false

            get '/prometheus/api/v1/*proxy_path', to: 'environments/prometheus_api#proxy', as: :prometheus_api

            get '/sample_metrics', to: 'environments/sample_metrics#query'
          end

          collection do
            get :metrics, action: :metrics_redirect
            get :folder, path: 'folders/*id', constraints: { format: /(html|json)/ }
            get :search
          end

          resources :deployments, only: [:index] do
            member do
              get :metrics
              get :additional_metrics
            end
          end
        end

        namespace :performance_monitoring do
          resources :dashboards, only: [:create] do
            collection do
              put '/:file_name', to: 'dashboards#update', constraints: { file_name: /.+\.yml/ }
            end
          end
        end

        resources :alert_management, only: [:index] do
          get 'details', on: :member
        end

        namespace :error_tracking do
          resources :projects, only: :index
        end

        resources :error_tracking, only: [:index], controller: :error_tracking do
          collection do
            get ':issue_id/details',
              to: 'error_tracking#details',
              as: 'details'
            get ':issue_id/stack_trace',
              to: 'error_tracking/stack_traces#index',
              as: 'stack_trace'
            put ':issue_id',
              to: 'error_tracking#update',
              as: 'update'
          end
        end

        namespace :design_management do
          namespace :designs, path: 'designs/:design_id(/:sha)', constraints: -> (params) { params[:sha].nil? || Gitlab::Git.commit_id?(params[:sha]) } do
            resource :raw_image, only: :show
            resources :resized_image, only: :show, constraints: -> (params) { DesignManagement::DESIGN_IMAGE_SIZES.include?(params[:id]) }
          end
        end

        get '/snippets/:snippet_id/raw/:ref/*path',
          to: 'snippets/blobs#raw',
          format: false,
          as: :snippet_blob_raw,
          constraints: { snippet_id: /\d+/ }

        resources :jira_issues, only: [:index]
        draw :issues
        draw :merge_requests
        draw :pipelines

        # The wiki and repository routing contains wildcard characters so
        # its preferable to keep it below all other project routes
        draw :repository_scoped
        draw :repository
        draw :wiki

        namespace :import do
          resource :jira, only: [:show], controller: :jira
        end
      end
      # End of the /-/ scope.

      # All new routes should go under /-/ scope.
      # Look for scope '-' at the top of the file.

      #
      # Templates
      #
      get '/templates/:template_type/:key' => 'templates#show',
          as: :template,
          defaults: { format: 'json' },
          constraints: { key: %r{[^/]+}, template_type: %r{issue|merge_request}, format: 'json' }

      get '/description_templates/names/:template_type',
          to: 'templates#names',
          as: :template_names,
          defaults: { format: 'json' },
          constraints: { template_type: %r{issue|merge_request}, format: 'json' }

      resource :pages, only: [:show, :update, :destroy] do # rubocop: disable Cop/PutProjectRoutesUnderScope
        resources :domains, except: :index, controller: 'pages_domains', constraints: { id: %r{[^/]+} } do # rubocop: disable Cop/PutProjectRoutesUnderScope
          member do
            post :verify
            post :retry_auto_ssl
            delete :clean_certificate
          end
        end
      end

      resources :snippets, concerns: :awardable, constraints: { id: /\d+/ } do # rubocop: disable Cop/PutProjectRoutesUnderScope
        member do
          get :raw
          post :mark_as_spam
        end
      end

      # Serve snippet routes under /-/snippets.
      # To ensure an old unscoped routing is used for the UI we need to
      # add prefix 'as' to the scope routing and place it below original routing.
      # Issue https://gitlab.com/gitlab-org/gitlab/-/issues/29572
      scope '-', as: :scoped do
        resources :snippets, concerns: :awardable, constraints: { id: /\d+/ } do # rubocop: disable Cop/PutProjectRoutesUnderScope
          member do
            get :raw
            post :mark_as_spam
          end
        end
      end

      namespace :prometheus do
        resources :alerts, constraints: { id: /\d+/ }, only: [:index, :create, :show, :update, :destroy] do # rubocop: disable Cop/PutProjectRoutesUnderScope
          post :notify, on: :collection
          member do
            get :metrics_dashboard
          end
        end

        resources :metrics, constraints: { id: %r{[^\/]+} }, only: [:index, :new, :create, :edit, :update, :destroy] do # rubocop: disable Cop/PutProjectRoutesUnderScope
          get :active_common, on: :collection
          post :validate_query, on: :collection
        end
      end

      post 'alerts/notify', to: 'alerting/notifications#create'

      draw :legacy_builds

      resources :hooks, only: [:index, :create, :edit, :update, :destroy], constraints: { id: /\d+/ } do # rubocop: disable Cop/PutProjectRoutesUnderScope
        member do
          post :test
        end

        resources :hook_logs, only: [:show] do # rubocop: disable Cop/PutProjectRoutesUnderScope
          member do
            post :retry
          end
        end
      end

      resources :container_registry, only: [:index, :destroy, :show], # rubocop: disable Cop/PutProjectRoutesUnderScope
                                     controller: 'registry/repositories'

      namespace :registry do
        resources :repository, only: [] do # rubocop: disable Cop/PutProjectRoutesUnderScope
          # We default to JSON format in the controller to avoid ambiguity.
          # `latest.json` could either be a request for a tag named `latest`
          # in JSON format, or a request for tag named `latest.json`.
          scope format: false do
            resources :tags, only: [:index, :destroy], # rubocop: disable Cop/PutProjectRoutesUnderScope
                             constraints: { id: Gitlab::Regex.container_registry_tag_regex } do
              collection do
                delete :bulk_destroy
              end
            end
          end
        end
      end

      resources :notes, only: [:create, :destroy, :update], concerns: :awardable, constraints: { id: /\d+/ } do # rubocop: disable Cop/PutProjectRoutesUnderScope
        member do
          delete :delete_attachment
          post :resolve
          delete :resolve, action: :unresolve
        end
      end

      get 'noteable/:target_type/:target_id/notes' => 'notes#index', as: 'noteable_notes'

      resources :todos, only: [:create] # rubocop: disable Cop/PutProjectRoutesUnderScope

      resources :uploads, only: [:create] do # rubocop: disable Cop/PutProjectRoutesUnderScope
        collection do
          get ":secret/:filename", action: :show, as: :show, constraints: { filename: %r{[^/]+} }, format: false, defaults: { format: nil }
          post :authorize
        end
      end

      resources :runners, only: [:index, :edit, :update, :destroy, :show] do # rubocop: disable Cop/PutProjectRoutesUnderScope
        member do
          post :resume
          post :pause
        end

        collection do
          post :toggle_shared_runners
          post :toggle_group_runners
        end
      end

      resources :runner_projects, only: [:create, :destroy] # rubocop: disable Cop/PutProjectRoutesUnderScope
      resources :badges, only: [:index] do # rubocop: disable Cop/PutProjectRoutesUnderScope
        collection do
          scope '*ref', constraints: { ref: Gitlab::PathRegex.git_reference_regex } do
            constraints format: /svg/ do
              get :pipeline
              get :coverage
            end
          end
        end
      end

      scope :usage_ping, controller: :usage_ping do
        post :web_ide_clientside_preview
        post :web_ide_pipelines_count
      end

      resources :web_ide_terminals, path: :ide_terminals, only: [:create, :show], constraints: { id: /\d+/, format: :json } do # rubocop: disable Cop/PutProjectRoutesUnderScope
        member do
          post :cancel
          post :retry
        end

        collection do
          post :check_config
        end
      end

      # Deprecated unscoped routing.
      # Issue https://gitlab.com/gitlab-org/gitlab/issues/118849
      scope as: 'deprecated' do
        draw :pipelines
        draw :repository
      end

      # All new routes should go under /-/ scope.
      # Look for scope '-' at the top of the file.

      # Legacy routes.
      # Introduced in 12.0.
      # Should be removed with https://gitlab.com/gitlab-org/gitlab/issues/28848.
      Gitlab::Routing.redirect_legacy_paths(self, :mirror, :tags,
                                            :cycle_analytics, :mattermost, :variables, :triggers,
                                            :environments, :protected_environments, :error_tracking, :alert_management,
                                            :serverless, :clusters, :audit_events, :wikis, :merge_requests,
                                            :vulnerability_feedback, :security, :dependencies, :issues)
    end

    # rubocop: disable Cop/PutProjectRoutesUnderScope
    resources(:projects,
              path: '/',
              constraints: { id: Gitlab::PathRegex.project_route_regex },
              only: [:edit, :show, :update, :destroy]) do
      member do
        put :transfer
        delete :remove_fork
        post :archive
        post :unarchive
        post :housekeeping
        post :toggle_star
        post :preview_markdown
        post :export
        post :remove_export
        post :generate_new_export
        get :download_export
        get :activity
        get :refs
        put :new_issuable_address
      end
    end
    # rubocop: enable Cop/PutProjectRoutesUnderScope
  end
end
