# frozen_string_literal: true

module Gitlab
  module Sitemap
    class FileGenerator
      include Gitlab::Routing

      def initialize(index)
        @index = index
      end

      def generate
        sitemap_file = Sitemap::File.new

        add_generic_urls

        if Gitlab.com?
          gitlab_public_projects.find_each do |project|
            urls = Sitemap::Project.new(project).extract_sitemap_urls

            urls.each do |url|
              sitemap_file.add_url(url)
            rescue Exception
              sitemap_file.save
              @index.add_index(saved_url)
              sitemap_file = Sitemap::File.new
              retry
            end
          end
        else
          url = sitemap_file.save
          # Add the file to the index
          @index.add_index(url)
        end
      end

      private



      def add_generic_urls
        generic_urls.each do |url|
          add_url(url)
        end
      end

      def generic_urls
        [explore_projects_url,
        starred_explore_projects_url,
        trending_explore_projects_url,
        explore_snippets_url,
        explore_groups_url,
        help_url]
      end

      def gitlab_group
        Group.find_by(path: 'gitlab-org', namespace_id: nil)
      end

      def gitlab_public_projects
        return [] unless gitlab_group
        # TODO: preload routes
        gitlab_group.projects.public_to_user
      end
    end
  end
end
