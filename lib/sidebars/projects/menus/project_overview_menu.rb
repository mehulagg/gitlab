# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      class ProjectOverviewMenu < ::Sidebars::Menu
        override :configure_menu_items
        def configure_menu_items
          add_item(details_menu_item)
          add_item(activity_menu_item)
          add_item(releases_menu_item)

          true
        end

        override :link
        def link
          project_path(context.project)
        end

        override :extra_container_html_options
        def extra_container_html_options
          {
            class: 'shortcuts-project rspec-project-link'
          }
        end

        override :extra_container_html_options
        def nav_link_html_options
          { class: 'home' }
        end

        override :title
        def title
          _('Project overview')
        end

        override :sprite_icon
        def sprite_icon
          'home'
        end

        private

        def details_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Details'),
            link: project_path(context.project),
            active_routes: { path: 'projects#show' },
            item_id: :project_overview,
            container_html_options: {
              aria: { label: _('Project details') },
              class: 'shortcuts-project'
            }
          )
        end

        def activity_menu_item
          ::Sidebars::MenuItem.new(
            title: _('Activity'),
            link: activity_project_path(context.project),
            active_routes: { path: 'projects#activity' },
            item_id: :activity,
            container_html_options: { class: 'shortcuts-project-activity' }
          )
        end

        def releases_menu_item
          return unless can?(context.current_user, :read_release, context.project)
          return if context.project.empty_repo?

          ::Sidebars::MenuItem.new(
            title: _('Releases'),
            link: project_releases_path(context.project),
            item_id: :releases,
            active_routes: { controller: :releases },
            container_html_options: { class: 'shortcuts-project-releases' }
          )
        end
      end
    end
  end
end
