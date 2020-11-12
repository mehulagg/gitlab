# frozen_string_literal: true

module Ci
  class ListConfigVariablesService < ::BaseService
    include ReactiveCaching

    self.reactive_cache_key = ->(service) { service.reactive_cache_key }
    self.reactive_cache_work_type = :no_dependency
    self.reactive_cache_worker_finder = ->(_id, *args) { from_cache(*args) }

    def self.from_cache(project_id, user_id, sha)
      project = Project.find(project_id)
      user = User.find(user_id)

      new(project, user, sha: sha)
    end

    def execute
      # We don't want to return `nil` (empty variable list to users).
      # So we run `process_without_cache` when the cache is empty. Which should be fine.
      read_from_cache || process_without_cache
    end

    def calculate_reactive_cache(*)
      process_without_cache
    end

    def reactive_cache_key
      [project.id, current_user.id, params[:sha]]
    end

    # Required for ReactiveCaching; Usage overridden by
    # self.reactive_cache_worker_finder
    def id
      nil
    end

    private

    def read_from_cache
      with_reactive_cache(*reactive_cache_key) { |result| result }
    end

    def process_without_cache
      config = project.ci_config_for(params[:sha])
      return {} unless config

      result = Gitlab::Ci::YamlProcessor.new(config, project: project,
                                                     user:    current_user,
                                                     sha:     params[:sha]).execute

      result.valid? ? result.variables_with_data : {}
    end
  end
end
