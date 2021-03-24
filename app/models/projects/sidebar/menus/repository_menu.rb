# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      class RepositoryMenu < ::Sidebar::Menu
        def initialize(context)
          super

          add_item(Items::FilesMenuItem.new(context))
          add_item(Items::CommitsMenuItem.new(context))
          add_item(Items::BranchesMenuItem.new(context))
          add_item(Items::TagsMenuItem.new(context))
          add_item(Items::ContributorsMenuItem.new(context))
          add_item(Items::GraphsMenuItem.new(context))
          add_item(Items::CompareMenuItem.new(context))
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

Projects::Sidebar::Menus::RepositoryMenu.prepend_if_ee('EE::Projects::Sidebar::Menus::RepositoryMenu')
