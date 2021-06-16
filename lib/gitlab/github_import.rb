# frozen_string_literal: true

module Gitlab
  module GithubImport
    COUNTER_LIST_KEY = 'github-importer/counter-list/%{project}'

    class << self
      def refmap
        [:heads, :tags, '+refs/pull/*/head:refs/merge-requests/*/head']
      end

      def new_client_for(project, token: nil, host: nil, parallel: true)
        token_to_use = token || project.import_data&.credentials&.fetch(:user)
        Client.new(
          token_to_use,
          host: host.presence || formatted_import_url(project),
          parallel: parallel
        )
      end

      # Returns the ID of the ghost user.
      def ghost_user_id
        key = 'github-import/ghost-user-id'

        Gitlab::Cache::Import::Caching.read_integer(key) || Gitlab::Cache::Import::Caching.write(key, User.select(:id).ghost.id)
      end

      # Get formatted GitHub import URL. If github.com is in the import URL, this will return nil and octokit will use the default github.com API URL
      def formatted_import_url(project)
        url = URI.parse(project.import_url)

        unless url.host == 'github.com'
          url.user = nil
          url.password = nil
          url.path = "/api/v3"
          url.to_s
        end
      end

      def increment_object_count(project, key)
        save_counter_name(project, key)

        Gitlab::Cache::Import::Caching.increment(key)
      end

      def objects_imported(project)
        Gitlab::Cache::Import::Caching
          .values_from_set(counter_list_key(project))
          .each_with_object({}) do |counter, result|
            humanized_name = counter.split('/').last
            result[humanized_name] = Gitlab::Cache::Import::Caching.read_integer(counter)
          end
      end

      private

      def save_counter_name(project, name)
        Gitlab::Cache::Import::Caching.set_add(counter_list_key(project), name)
      end

      def counter_list_key(project)
        COUNTER_LIST_KEY % { project: project.id }
      end
    end
  end
end
