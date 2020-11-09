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
          full_path = group.full_path

          [
           "#{base_url}#{full_path}",
           "#{base_url}groups/#{full_path}/-/issues",
           "#{base_url}groups/#{full_path}/-/merge_requests",
           "#{base_url}groups/#{full_path}/-/packages",
          ].tap do |urls|
            urls << "#{base_url}groups/#{full_path}/-/epics" if group.feature_available?(:epics)
          end
        end

        def extract_from_project(project)
          full_path = project.full_path

          [
           "#{base_url}#{full_path}"
          ].tap do |urls|
            urls << "#{base_url}#{full_path}/-/merge_requests" if project.feature_available?(:merge_requests, nil)
            urls << "#{base_url}#{full_path}/-/issues" if project.feature_available?(:issues, nil)
            urls << "#{base_url}#{full_path}/-/snippets" if project.feature_available?(:snippets, nil)
            urls << "#{base_url}#{full_path}/-/wikis/home" if project.feature_available?(:wiki, nil)
          end
        end

        def base_url
          @@base_url ||= root_url
        end
      end

      private_class_method :base_url
    end
  end
end
