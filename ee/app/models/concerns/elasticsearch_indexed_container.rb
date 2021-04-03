# frozen_string_literal: true

module ElasticsearchIndexedContainer
  extend ActiveSupport::Concern

  included do
    after_commit :index, on: :create
    after_commit :delete_from_index, on: :destroy
    after_commit :invalidate_elasticsearch_indexes_cache!, on: [:create, :destroy]
  end

  def invalidate_elasticsearch_indexes_cache!
    self.class.invalidate_elasticsearch_indexes_cache!
  end

  class_methods do
    def target_ids
      pluck(target_attr_name)
    end

    def remove_all(except: [])
      self.where.not(target_attr_name => except).each_batch do |batch, _index|
        batch.destroy_all # #rubocop:disable Cop/DestroyAll
      end
    end

    def invalidate_elasticsearch_indexes_cache!
      ::Gitlab::CurrentSettings.invalidate_elasticsearch_indexes_cache!
    end
  end
end
