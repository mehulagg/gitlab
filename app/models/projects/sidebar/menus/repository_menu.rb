# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      class RepositoryMenu < ::Sidebar::Menu
        def initialize(current_user, project, current_ref)
          super(current_user, project)

          add_item(Items::FilesMenuItem.new(current_user, project, current_ref))
          add_item(Items::CommitsMenuItem.new(current_user, project, current_ref))
          add_item(Items::BranchesMenuItem.new(current_user, project))
          add_item(Items::TagsMenuItem.new(current_user, project))
          add_item(Items::ContributorsMenuItem.new(current_user, project, current_ref))
          add_item(Items::GraphsMenuItem.new(current_user, project, current_ref))
          add_item(Items::CompareMenuItem.new(current_user, project, current_ref))
        end

        override :link_to_href
        def link_to_href
          project_tree_path(container)
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

        override :sprite_icon
        def sprite_icon
          'doc-text'
        end

        override :render?
        def render?
          !container.empty_repo? && can?(current_user, :download_code, container)
        end
      end
    end
  end
end


# - if project_nav_tab? :files
#   = nav_link(controller: sidebar_repository_paths, unless: -> { current_path?('projects/graphs#charts') }) do
#     = link_to project_tree_path(@project), class: 'shortcuts-tree', data: { qa_selector: "repository_link" } do
#       .nav-icon-container
#         = sprite_icon('doc-text')
#       %span.nav-item-name#js-onboarding-repo-link <---- ******
#         = _('Repository')

#     %ul.sidebar-sub-level-items
#       = nav_link(controller: sidebar_repository_paths, html_options: { class: "fly-out-top-item" } ) do
#         = link_to project_tree_path(@project) do
#           %strong.fly-out-top-item-name
#             = _('Repository')
#       %li.divider.fly-out-top-item
#       = nav_link(controller: %w(tree blob blame edit_tree new_tree find_file)) do
#         = link_to project_tree_path(@project) do
#           = _('Files')

#       = nav_link(controller: [:commit, :commits]) do
#         = link_to project_commits_path(@project, current_ref), id: 'js-onboarding-commits-link' do
#           = _('Commits')

#       = nav_link(html_options: {class: branches_tab_class}) do
#         = link_to project_branches_path(@project), data: { qa_selector: "branches_link" }, id: 'js-onboarding-branches-link' do
#           = _('Branches')

#       = nav_link(controller: [:tags]) do
#         = link_to project_tags_path(@project), data: { qa_selector: "tags_link" } do
#           = _('Tags')

#       = nav_link(path: 'graphs#show') do
#         = link_to project_graph_path(@project, current_ref) do
#           = _('Contributors')

#       = nav_link(controller: %w(network)) do
#         = link_to project_network_path(@project, current_ref) do
#           = _('Graph')

#       = nav_link(controller: :compare) do
#         = link_to project_compare_index_path(@project, from: @repository.root_ref, to: current_ref) do
#           = _('Compare')

#       = render_if_exists 'projects/sidebar/repository_locked_files' <---- ******
