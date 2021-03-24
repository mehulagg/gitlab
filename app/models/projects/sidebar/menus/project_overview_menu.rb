# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      class ProjectOverviewMenu < ::Sidebar::Menu
        def initialize(current_user, project)
          super(current_user, project)

          add_item(Items::DetailsMenuItem.new(current_user, project))
          add_item(Items::ActivityMenuItem.new(current_user, project))
          add_item(Items::ReleasesMenuItem.new(current_user, project))
        end

        override :link_to_href
        def link_to_href
          project_path(container)
        end

        override :link_to_attributes
        def link_to_attributes
          {
            class: 'shortcuts-project rspec-project-link',
            data: { qa_selector: 'project_link' }
          }
        end

        # override :nav_link_params
        # def nav_link_params
        #   { path: 'projects#show' }
        # end

        override :menu_name
        def menu_name
          _('Project overview')
        end

        override :sprite_icon
        def sprite_icon
          'home'
        end
      end
    end
  end
end
