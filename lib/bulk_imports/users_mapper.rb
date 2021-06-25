# frozen_string_literal: true

module BulkImports
  class UsersMapper
    SOURCE_USER_IDS_CACHE_KEY = 'bulk_imports/%{bulk_import}/%{entity}/source_user_ids'

    def initialize(context:)
      @context = context
      @cache_key = SOURCE_USER_IDS_CACHE_KEY % {
        bulk_import: @context.bulk_import.id,
        entity: @context.entity.id
      }
    end

    def map
    end

    def default_user_id
      @user.id
    end

    def include?(old_user_id)
      map.has_key?(old_user_id)
    end

    def cache_source_user_id(source_id, destination_id)
      ::Gitlab::Cache::Import::Caching.hash_add(@cache_key, source_id, destination_id)
    end

    private

    def missing_keys_tracking_hash
      Hash.new do |_, key|
        @user.id
      end
    end
  end
end
