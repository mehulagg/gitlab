# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class Milestones < ::Sidebars::MenuItem
            override :link
            def link
              project_milestones_path(context.project)
            end

            override :active_routes
            def active_routes
              { controller: :milestones }
            end

            override :title
            def title
              _('Milestones')
            end
          end
        end
      end
    end
  end
end
