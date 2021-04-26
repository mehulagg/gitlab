# frozen_string_literal: true

module Nav
  module TopNavHelper
    def  top_nav_view_model
      return top_nav_anonymous_view_model unless current_user

      primary = top_nav_view_model_primary
      secondary = top_nav_view_model_secondary

      active = find_active(primary + secondary)
      active_title = active ? active[:title] : 'Menu'

      {
        primary: primary,
        secondary: secondary,
        active_title: active_title,
        views: {
          projects_view: container_view_props(container_type: 'projects'),
          groups_view: container_view_props(container_type: 'groups')
        }
      }
    end

    def top_nav_anonymous_view_model
      primary = []

      if explore_nav_link?(:projects)
        primary.push({
                       id: 'projects',
                       title: _('Projects'),
                       active: active_nav_link?(path: ['dashboard#show', 'root#show', 'projects#trending', 'projects#starred', 'projects#index']),
                       icon: 'project',
                       href: explore_root_path
                     })
      end

      if explore_nav_link?(:groups)
        primary.push({
                       id: 'groups',
                       title: _('Groups'),
                       active: active_nav_link?(controller: [:groups, 'groups/milestones', 'groups/group_members']),
                       icon: 'group',
                       href: explore_groups_path
                     })
      end

      if explore_nav_link?(:snippets)
        primary.push({
                       id: 'snippets',
                       title: _('Snippets'),
                       active: active_nav_link?(controller: :snippets),
                       icon: 'snippet',
                       href: explore_snippets_path
                     })
      end

      active = find_active(primary)
      active_title = active ? active[:title] : 'Menu'

      {
        primary: primary,
        active_title: active_title,
      }
    end

    def top_nav_responsive_view_model
      top_nav_view_model
    end

    private

    def top_nav_view_model_primary
      primary = []

      # TODO: Pull out a PORO object to encapsulate properties of a link
      if dashboard_nav_link?(:projects)
        primary.push({
                       id: 'project',
                       title: 'Projects',
                       icon: 'project',
                       active: active_nav_link?(path: ['root#index', 'projects#trending', 'projects#starred', 'dashboard/projects#index']),
                       view: 'projects-view'
                     })
      end

      if dashboard_nav_link?(:groups)
        primary.push({
                       id: 'groups',
                       title: 'Groups',
                       icon: 'group',
                       active: active_nav_link?(path: ['dashboard/groups', 'explore/groups']),
                       view: 'groups-view'
                     })
      end

      if dashboard_nav_link?(:milestones)
        primary.push({
                       id: 'milestones',
                       title: 'Milestones',
                       active: active_nav_link?(controller: 'dashboard/milestones'),
                       icon: 'clock',
                       href: dashboard_milestones_path
                     })
      end

      if dashboard_nav_link?(:milestones)
        primary.push({
                       id: 'snippets',
                       title: 'Snippets',
                       active: active_nav_link?(controller: 'dashboard/snippets'),
                       icon: 'snippet',
                       href: dashboard_snippets_path
                     })
      end

      if dashboard_nav_link?(:activity)
        primary.push({
                       id: 'activity',
                       title: 'Activity',
                       active: active_nav_link?(path: 'dashboard#activity'),
                       icon: 'history',
                       href: activity_dashboard_path
                     })
      end

      primary
    end

    def top_nav_view_model_secondary
      secondary = []

      if current_user&.can_admin_all_resources?
        secondary.push({
                         id: 'admin',
                         title: 'Admin',
                         active: active_nav_link?(controller: 'admin/dashboard'),
                         icon: 'admin',
                         href: admin_root_path
                       })
      end

      secondary
    end

    def find_active(items)
      items.find { |x| x[:active] }
    end

    def container_view_props(container_type:)
      container = container_type == 'projects' ? current_project : current_group

      {
        namespace: container_type,
        currentUserName: current_user&.username,
        currentItem: container,
        linksPrimary: container_type == 'projects' ? projects_links_primary : groups_links_primary,
        linksSecondary: container_type == 'projects' ? projects_links_secondary : groups_links_secondary
      }
    end

    def current_project
      return {} unless @project&.persisted?

      {
        id: @project.id,
        name: @project.name,
        namespace: @project.full_name,
        webUrl: project_path(@project),
        avatarUrl: @project.avatar_url
      }
    end

    def current_group
      return {} unless @group&.persisted?

      {
        id: @group.id,
        name: @group.name,
        namespace: @group.full_name,
        webUrl: group_path(@group),
        avatarUrl: @group.avatar_url
      }
    end

    # These project links come from `app/views/layouts/nav/projects_dropdown/_show.html.haml`
    def projects_links_primary
      [
        {
          title: _('Your projects'),
          href: dashboard_projects_path
        },
        {
          title: _('Starred projects'),
          href: starred_dashboard_projects_path
        },
        {
          title: _('Explore projects'),
          href: explore_root_path
        }
      ]
    end

    def projects_links_secondary
      [
        {
          title: _('Create new project'),
          href: new_project_path
        }
      ]
    end

    # These group links come from `app/views/layouts/nav/groups_dropdown/_show.html.haml`
    def groups_links_primary
      [
        {
          title: _('Your groups'),
          href: dashboard_groups_path
        },
        {
          title: _('Explore groups'),
          href: explore_groups_path
        }
      ]
    end

    def groups_links_secondary
      [
        {
          title: _('Create group'),
          href: new_group_path(anchor: 'create-group-pane')
        },
        {
          title: _('Import group'),
          href: new_group_path(anchor: 'import-group-pane')
        }
      ]
    end
  end
end

Nav::TopNavHelper.prepend_if_ee('EE::Nav::TopNavHelper')
