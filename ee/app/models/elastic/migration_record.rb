# frozen_string_literal: true

module Elastic
  class MigrationRecord
    attr_reader :version, :name, :filename

    delegate :migrate, :skip_migration?, :completed?, to: :migration

    def initialize(version:, name:, filename:)
      @version = version
      @name = name
      @filename = filename
      @migration = nil
    end

    def save!(completed:)
      raise 'Migrations index is not found' unless helper.index_exists?(index_name: index_name)

      client.index index: index_name, type: '_doc', id: version, body: { completed: completed }
    end

    def persisted?
      load_from_index.present?
    end

    def load_from_index
      client.get(index: index_name, id: version)
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      nil
    end

    def self.persisted_versions(completed:)
      helper = Gitlab::Elastic::Helper.default
      helper.client
            .search(index: helper.migrations_index_name, body: { query: { term: { completed: completed } } })
            .dig('hits', 'hits')
            .map { |v| v['_id'].to_i }
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      []
    end

    private

    def migration
      @migration ||= load_migration
    end

    def load_migration
      require(File.expand_path(filename))
      name.constantize.new version
    end

    def index_name
      helper.migrations_index_name
    end

    def client
      helper.client
    end

    def helper
      Gitlab::Elastic::Helper.default
    end
  end
end
