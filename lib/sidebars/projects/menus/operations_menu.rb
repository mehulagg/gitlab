# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      class OperationsMenu < ::Sidebars::Menu
        override :configure_menu_items
        def configure_menu_items
          return false unless context.project.feature_available?(:operations, context.current_user)

          add_item(metrics_dashboard_menu_item)
          add_item(logs_menu_item)
          add_item(tracing_menu_item)
          add_item(error_tracking_menu_item)
          add_item(alert_management_menu_item)
          add_item(incidents_menu_item)
          add_item(serverless_menu_item)
          add_item(terraform_menu_item)
          add_item(kubernetes_menu_item)
          add_item(environments_menu_item)
          add_item(feature_flags_menu_item)
          add_item(product_analytics_menu_item)

          true
        end

        override :link
        def link
          if can?(context.current_user, :read_environment, context.project)
            metrics_project_environments_path(context.project)
          else
            project_feature_flags_path(context.project)
          end
        end

        override :extra_container_html_options
        def extra_container_html_options
          {
            class: 'shortcuts-operations'
          }
        end

        override :title
        def title
          _('Operations')
        end

        override :sprite_icon
        def sprite_icon
          Feature.enabled?(:sidebar_refactor, context.current_user) ? 'monitor' : 'cloud-gear'
        end

        override :active_routes
        def active_routes
          { controller: [:user, :gcp] }
        end

        private

        def metrics_dashboard_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Metrics'),
            link: project_metrics_dashboard_path(context.project),
            active_routes: { path: 'metrics_dashboard#show' },
            container_html_options: { class: 'shortcuts-metrics' },
            item_id: :metrics,
            render: -> { can?(context.current_user, :metrics_dashboard, context.project) }
          )
        end

        def logs_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Logs'),
            link: project_logs_path(context.project),
            active_routes: { path: 'logs#index' },
            item_id: :logs,
            render: -> do
              can?(context.current_user, :read_environment, context.project) &&
                can?(context.current_user, :read_pod_logs, context.project)
            end
          )
        end

        def tracing_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Tracing'),
            link: project_tracing_path(context.project),
            active_routes: { path: 'tracings#show' },
            item_id: :tracing,
            render: -> do
              can?(context.current_user, :read_environment, context.project) &&
                can?(context.current_user, :admin_project, context.project)
            end
          )
        end

        def error_tracking_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Error Tracking'),
            link: project_error_tracking_index_path(context.project),
            active_routes: { controller: :error_tracking },
            item_id: :error_tracking,
            render: -> { can?(context.current_user, :read_sentry_issue, context.project) }
          )
        end

        def alert_management_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Alerts'),
            link: project_alert_management_index_path(context.project),
            active_routes: { controller: :alert_management },
            item_id: :alert_management,
            render: -> { can?(context.current_user, :read_alert_management_alert, context.project) }
          )
        end

        def incidents_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Incidents'),
            link: project_incidents_path(context.project),
            active_routes: { controller: [:incidents, :incident_management] },
            item_id: :incidents,
            render: -> { can?(context.current_user, :read_issue, context.project) }
          )
        end

        def serverless_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Serverless'),
            link: project_serverless_functions_path(context.project),
            active_routes: { controller: :functions },
            item_id: :serverless,
            render: -> do
              Feature.disabled?(:sidebar_refactor, context.current_user) &&
                can?(context.current_user, :read_cluster, context.project)
            end
          )
        end

        def terraform_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Terraform'),
            link: project_terraform_index_path(context.project),
            active_routes: { controller: :terraform },
            item_id: :terraform,
            render: -> do
              Feature.disabled?(:sidebar_refactor, context.current_user) &&
                can?(context.current_user, :read_terraform_state, context.project)
            end
          )
        end

        def kubernetes_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Kubernetes'),
            link: project_clusters_path(context.project),
            active_routes: { controller: [:cluster_agents, :clusters] },
            container_html_options: { class: 'shortcuts-kubernetes' },
            hint_html_options: kubernetes_hint_html_options,
            item_id: :kubernetes,
            render: -> do
              Feature.disabled?(:sidebar_refactor, context.current_user) &&
                can?(context.current_user, :read_cluster, context.project)
            end
          )
        end

        def kubernetes_hint_html_options
          return {} unless context.show_cluster_hint

          { disabled: true,
            data: { trigger: 'manual',
              container: 'body',
              placement: 'right',
              highlight: UserCalloutsHelper::GKE_CLUSTER_INTEGRATION,
              highlight_priority: UserCallout.feature_names[:GKE_CLUSTER_INTEGRATION],
              dismiss_endpoint: user_callouts_path,
              auto_devops_help_path: help_page_path('topics/autodevops/index.md') } }
        end

        def environments_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Environments'),
            link: project_environments_path(context.project),
            active_routes: { controller: :environments },
            container_html_options: { class: 'shortcuts-environments' },
            item_id: :environments,
            render: -> { can?(context.current_user, :read_environment, context.project) }
          )
        end

        def feature_flags_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Feature Flags'),
            link: project_feature_flags_path(context.project),
            active_routes: { controller: :feature_flags },
            container_html_options: { class: 'shortcuts-feature-flags' },
            item_id: :feature_flags,
            render: -> { can?(context.current_user, :read_feature_flag, context.project) }
          )
        end

        def product_analytics_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Product Analytics'),
            link: project_product_analytics_path(context.project),
            active_routes: { controller: :product_analytics },
            item_id: :product_analytics,
            render: -> do
              Feature.enabled?(:product_analytics, context.project) &&
                can?(context.current_user, :read_product_analytics, context.project)
            end
          )
        end
      end
    end
  end
end

Sidebars::Projects::Menus::OperationsMenu.prepend_if_ee('EE::Sidebars::Projects::Menus::OperationsMenu')
