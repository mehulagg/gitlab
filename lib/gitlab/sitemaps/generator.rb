# frozen_string_literal: true

module Gitlab
  module Sitemaps
    class Generator
      class << self
        include Gitlab::Routing

        GITLAB_ORG_NAMESPACE = 'gitlab-org'.freeze

        def execute
          unless Gitlab.com?
            return "The sitemap can only be generated for the Gitlab.com"
          end

          file = Sitemaps::SitemapFile.new

          if gitlab_org_group
            file.add_elements(generic_urls)
            file.add_elements(gitlab_org_group)
            file.add_elements(gitlab_org_subgroups)
            file.add_elements(gitlab_org_projects)
            file.save
          else
            return "The namespace '#{GITLAB_ORG_NAMESPACE}' group was not found"
          end
        end

        private

        def generic_urls
          [explore_projects_url,
           explore_snippets_url,
           explore_groups_url,
           help_url]
        end

        def gitlab_org_group
          @gitlab_org_group ||= Group.find_by(path: 'gitlab-org', parent_id: nil)
        end

        def gitlab_org_subgroups
          GroupsFinder.new(
            nil,
            parent: gitlab_org_group,
            include_parent_descendants: true
          ).execute
        end

        def gitlab_org_projects
          GroupProjectsFinder.new(
            current_user: nil,
            group: gitlab_org_group,
            params: { non_archived: true },
            options: { include_subgroups: true }
          ).execute.includes(:project_feature, namespace: :route)
        end
      end
    end
  end
end
