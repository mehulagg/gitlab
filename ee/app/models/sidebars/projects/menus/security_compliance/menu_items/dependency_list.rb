# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class DependencyList < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_dependencies_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: item_name,
                data: { qa_selector: 'dependency_list_link' }
              }
            end

            override :nav_link_params
            def nav_link_params
              { path: 'projects/dependencies#index' }
            end

            override :item_name
            def item_name
              _('Dependency List')
            end

            override :render?
            def render?
              can?(context.current_user, :read_dependencies, context.project)
            end
          end
        end
      end
    end
  end
end
