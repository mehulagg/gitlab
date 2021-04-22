# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      class Infrastructure < ::Sidebars::Menu
        override :configure_menu_items
        def configure_menu_items
          add_item(kubernetes_menu_item)
          add_item(serverless_menu_item)
          add_item(terraform_menu_item)

          true
        end

        override :link
        def link
          project_clusters_path(context.project)
        end

        override :title
        def title
          _('Infrastructure')
        end

        override :sprite_icon
        def sprite_icon
          'cloud-gear'
        end

        private

        def kubernetes_menu_item
          return unless can?(context.current_user, :read_cluster, context.project)

          ::Sidebars::MenuItem.new(
            title: _('Kubernetes clusters'),
            link: project_clusters_path(context.project),
            active_routes: { controller: [:clusters, :user, :gcp] },
            item_id: :kubebrnetes,
            container_html_options: {
              class: 'shortcuts-kubernetes'
            }
          )
        end

        def serverless_menu_item
          return unless can?(context.current_user, :read_cluster, context.project)

          ::Sidebars::MenuItem.new(
            title: _('Serverless'),
            link: project_serverless_functions_path(context.project),
            active_routes: { controller: :functions },
            item_id: :serverless
          )
        end

        def terraform_menu_item
          return unless can?(context.current_user, :read_terraform_state, context.project)

          ::Sidebars::MenuItem.new(
            title: _('Terraform'),
            link: project_terraform_index_path(context.project),
            active_routes: { controller: :terraform },
            item_id: :terraform
          )
        end
      end
    end
  end
end
