# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Repository
        class Menu < ::Sidebars::Menu
          def initialize(context)
            super

            add_item(MenuItems::Files.new(context))
            add_item(MenuItems::Commits.new(context))
            add_item(MenuItems::Branches.new(context))
            add_item(MenuItems::Tags.new(context))
            add_item(MenuItems::Contributors.new(context))
            add_item(MenuItems::Graphs.new(context))
            add_item(MenuItems::Compare.new(context))
          end

          override :link_to_href
          def link_to_href
            project_tree_path(context.project)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              class: 'shortcuts-tree',
              data: { qa_selector: 'repository_link' }
            }
          end

          override :menu_name
          def menu_name
            _('Repository')
          end

          override :menu_name_html_options
          def menu_name_html_options
            {
              id: 'js-onboarding-repo-link'
            }
          end

          override :sprite_icon
          def sprite_icon
            'doc-text'
          end

          override :render?
          def render?
            !context.project.empty_repo? && can?(context.current_user, :download_code, context.project)
          end
        end
      end
    end
  end
end

Sidebars::Projects::Menus::Repository::Menu.prepend_if_ee('EE::Sidebars::Projects::Menus::Repository::Menu')
