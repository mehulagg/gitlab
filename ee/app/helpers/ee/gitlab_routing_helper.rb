module EE
  module GitlabRoutingHelper
    include ::ProjectsHelper
    include ::ApplicationSettingsHelper
    include ::API::Helpers::RelatedResourcesHelpers

    def geo_primary_web_url(project_or_wiki)
      File.join(::Gitlab::Geo.primary_node.url, project_or_wiki.full_path)
    end

    def geo_primary_ssh_url_to_repo(project_or_wiki)
      "#{::Gitlab::Geo.primary_node.clone_url_prefix}#{project_or_wiki.full_path}.git"
    end

    def geo_primary_http_url_to_repo(project_or_wiki)
      geo_primary_web_url(project_or_wiki) + '.git'
    end

    def geo_primary_default_url_to_repo(project_or_wiki)
      case default_clone_protocol
      when 'ssh'
        geo_primary_ssh_url_to_repo(project_or_wiki)
      else
        geo_primary_http_url_to_repo(project_or_wiki)
      end
    end

    def epic_path(entity, *args)
      group_epic_path(entity.group, entity, *args)
    end

    def license_management_api_url(project)
      api_v4_projects_managed_licenses_path(id: project.id)
    end

    def license_management_settings_path(project)
      project_settings_ci_cd_path(project, anchor: 'js-license-management')
    end
  end
end
