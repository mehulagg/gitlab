# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      class IssuesMenu < ::Sidebar::Menu
        def initialize(context)
          super

          add_item(Items::IssueListsMenuItem.new(context))
          add_item(Items::BoardsMenuItem.new(context))
          # add_item(Items::BranchesMenuItem.new(context))
          # add_item(Items::TagsMenuItem.new(context))
          # add_item(Items::ContributorsMenuItem.new(context))
          # add_item(Items::GraphsMenuItem.new(context))
          # add_item(Items::CompareMenuItem.new(context))
        end

        override :link_to_href
        def link_to_href
          project_issues_path(context.project)
        end

        override :link_to_attributes
        def link_to_attributes
          {
            class: 'shortcuts-issues qa-issues-item'
          }
        end

        override :menu_name
        def menu_name
          _('Issues')
        end

        override :menu_name_html_options
        def menu_name_html_options
          {
            id: 'js-onboarding-repo-link'
          }
        end

        override :sprite_icon
        def sprite_icon
          'issues'
        end

        override :render?
        def render?
          can?(context.current_user, :read_issue, context.project)
        end
      end
    end
  end
end

# Projects::Sidebar::Menus::IssuesMenu.prepend_if_ee('EE::Projects::Sidebar::Menus::IssuesMenu')


# - if project_nav_tab? :issues
#   = nav_link(controller: @project.issues_enabled? ? ['projects/issues', :labels, :milestones, :boards, :iterations] : 'projects/issues') do
#     = link_to project_issues_path(@project), class: 'shortcuts-issues qa-issues-item' do
#       .nav-icon-container
#         = sprite_icon('issues')
#       %span.nav-item-name#js-onboarding-issues-link
#         = _('Issues')
#       - if @project.issues_enabled? <--------- *********
#         %span.badge.badge-pill.count.issue_counter
#           = number_with_delimiter(@project.open_issues_count(current_user))

#     %ul.sidebar-sub-level-items
#       = nav_link(controller: 'projects/issues', action: :index, html_options: { class: "fly-out-top-item" } ) do
#         = link_to project_issues_path(@project) do
#           %strong.fly-out-top-item-name
#             = _('Issues')
#           - if @project.issues_enabled?
#             %span.badge.badge-pill.count.issue_counter.fly-out-badge
#               = number_with_delimiter(@project.open_issues_count(current_user))
#       %li.divider.fly-out-top-item







#       = nav_link(controller: :labels) do
#         = link_to project_labels_path(@project), title: _('Labels'), class: 'qa-labels-link' do
#           %span
#             = _('Labels')

#       = render 'projects/sidebar/issues_service_desk'

#       = nav_link(controller: :milestones) do
#         = link_to project_milestones_path(@project), title: _('Milestones'), class: 'qa-milestones-link' do
#           %span
#             = _('Milestones')

#       = render_if_exists 'layouts/nav/sidebar/project_iterations_link'
