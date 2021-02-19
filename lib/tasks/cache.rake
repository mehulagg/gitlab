# frozen_string_literal: true

namespace :cache do
  namespace :clear do
    desc "GitLab | Cache | Clear redis cache"
    task redis: :environment do
      cache_key_patterns = %W[#{Gitlab::Redis::Cache::CACHE_NAMESPACE}* projects/*/pipeline_status]

      ::Gitlab::Cleanup::Redis::BatchDeleteByPattern.new(cache_key_patterns).execute
    end

    desc "GitLab | Cache | Clear description templates redis cache"
    task description_templates: :environment do
      project_ids = ENV['project_ids'].split(',') if ENV['project_ids']

      ::Gitlab::Cleanup::Redis::BatchDeleteDescriptionTemplates.new(project_ids).execute
    end

    task all: [:redis]
  end

  task clear: 'cache:clear:redis'
end
