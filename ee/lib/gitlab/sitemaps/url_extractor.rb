# frozen_string_literal: true

# Generating the urls for the project and groups is the most
# expensive part of the sitemap generation because we need
# to call the Rails route helpers.
#
# We could hardcode them but if a route changes the sitemap
# urls will be invalid.
module Gitlab
  module Sitemaps
    class UrlExtractor
      class << self
        include Gitlab::Routing

        def extract(element)
          case element
          when String
            element
          when Group
            extract_from_group(element)
          when Project
            extract_from_project(element)
          end
        end

        def extract_from_group(group)
          [
           group_url(group),
           issues_group_url(group),
           merge_requests_group_url(group),
           group_packages_url(group),
           group_epics_url(group)
          ]
        end

        def extract_from_project(project)
          [
           project_url(project),
           project_issues_url(project),
           project_merge_requests_url(project)
          ].tap do |urls|
            urls << project_snippets_url(project) if project.snippets_enabled?
            urls << project_wiki_url(project, Wiki::HOMEPAGE) if project.wiki_enabled?
          end
        end
      end
    end
  end
end
