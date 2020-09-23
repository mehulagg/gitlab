# frozen_string_literal: true
module Elastic
  module ApplicationVersionedSearch
    extend ActiveSupport::Concern

    FORWARDABLE_INSTANCE_METHODS = [:es_id, :es_parent].freeze
    FORWARDABLE_CLASS_METHODS = [:elastic_search, :es_import, :es_type, :index_name, :document_type, :mapping, :mappings, :settings, :import].freeze

    def __elasticsearch__(&block)
      @__elasticsearch__ ||= ::Elastic::MultiVersionInstanceProxy.new(self)
    end

    # Should be overridden in the models where some records should be skipped
    def searchable?
      self.use_elasticsearch?
    end

    def use_elasticsearch?
      self.project&.use_elasticsearch?
    end

    def maintaining_elasticsearch?
      Gitlab::CurrentSettings.elasticsearch_indexing? && self.searchable?
    end

    def es_type
      self.class.es_type
    end

    included do
      delegate(*FORWARDABLE_INSTANCE_METHODS, to: :__elasticsearch__)

      class << self
        delegate(*FORWARDABLE_CLASS_METHODS, to: :__elasticsearch__)
      end

      # Add to the registry if it's a class (and not in intermediate module)
      Elasticsearch::Model::Registry.add(self) if self.is_a?(Class)

      if self < ActiveRecord::Base
        after_commit :maintain_elasticsearch_create, on: :create, if: :maintaining_elasticsearch?
        after_commit :maintain_elasticsearch_update, on: :update, if: :maintaining_elasticsearch?
        after_commit :maintain_elasticsearch_destroy, on: :destroy, if: :maintaining_elasticsearch?
      end
    end

    def maintain_elasticsearch_create
      ::Elastic::ProcessBookkeepingService.track!(self)
    end

    def maintain_elasticsearch_update
      ::Elastic::ProcessBookkeepingService.track!(self)
    end

    def maintain_elasticsearch_destroy
      ::Elastic::ProcessBookkeepingService.track!(self)
    end

    class_methods do
      def __elasticsearch__
        @__elasticsearch__ ||= ::Elastic::MultiVersionClassProxy.new(self)
      end
    end
  end
end
