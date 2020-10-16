# frozen_string_literal: true

module Gitlab
  module Sitemap
    class FileGenerator
      include Gitlab::Routing
      def initialize(index)
        @index = index
        @num_urls = 0
        @bytesize = 0
      end

      def generate
        add_generic_urls

        if Gitlab.com?
          gitlab_public_projects.find_each do |project|
            Sitemap::Project.new(project, )
          end
        end

        # TODO save
      end

      private

      def add_url(url)
        #redered_text = Url.new(url).render
        @num_urls += 1
        @bytesize += 1
      end

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
