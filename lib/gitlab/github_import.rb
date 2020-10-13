# frozen_string_literal: true

module Gitlab
  module GithubImport
    def self.refmap
      [:heads, :tags, '+refs/pull/*/head:refs/merge-requests/*/head']
    end

    def self.new_client_for(project, token: nil, host: nil, parallel: true)
      token_to_use = token || project.import_data&.credentials&.fetch(:user)
      host_to_use = self.get_host(project, host: host)
      Client.new(token_to_use, host: host_to_use, parallel: parallel)
    end

    # Returns the ID of the ghost user.
    def self.ghost_user_id
      key = 'github-import/ghost-user-id'

      Gitlab::Cache::Import::Caching.read_integer(key) || Gitlab::Cache::Import::Caching.write(key, User.select(:id).ghost.id)
    end

    def self.get_host(project, host: nil)
      if host.present?
        host
      else
        url = (project.import_url).sub(%r{\/\/.+@}, '//')
        if !url.include? "github.com"
          (URI.join url, '/').to_s + "api/v3"
        end
      end
    end
  end
end
