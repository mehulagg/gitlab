# frozen_string_literal: true

module Gitlab
  module GithubImport
    COUNTER_LIST_KEY = 'github-importer/counter-list/%{project}'

    def self.refmap
      [:heads, :tags, '+refs/pull/*/head:refs/merge-requests/*/head']
    end

    def self.new_client_for(project, token: nil, host: nil, parallel: true)
      token_to_use = token || project.import_data&.credentials&.fetch(:user)
      Client.new(
        token_to_use,
        host: host.presence || self.formatted_import_url(project),
        parallel: parallel
      )
    end

    # Returns the ID of the ghost user.
    def self.ghost_user_id
      key = 'github-import/ghost-user-id'

      Gitlab::Cache::Import::Caching.read_integer(key) || Gitlab::Cache::Import::Caching.write(key, User.select(:id).ghost.id)
    end

    # Get formatted GitHub import URL. If github.com is in the import URL, this will return nil and octokit will use the default github.com API URL
    def self.formatted_import_url(project)
      url = URI.parse(project.import_url)

      unless url.host == 'github.com'
        url.user = nil
        url.password = nil
        url.path = "/api/v3"
        url.to_s
      end
    end

    def self.save_counter_name(project, name)
      ::Gitlab::Cache::Import::Caching.set_add(counter_list_key(project), name)
    end

    def self.objects_imported(project)
      caching = ::Gitlab::Cache::Import::Caching

      caching
        .values_from_set(counter_list_key(project))
        .each_with_object({}) do |counter, result|
          humanized_name = counter.split('/').last
          result[humanized_name] = caching.read_integer(counter)
        end
    end

    def self.counter_list_key(project)
      COUNTER_LIST_KEY % { project: project.id }
    end
  end
end
