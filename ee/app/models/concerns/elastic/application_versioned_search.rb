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

      associations_to_update = associations_needing_elasticsearch_update
      unless associations_to_update.blank?
        ElasticAssociationIndexerWorker.perform_async(self.class.name, id, associations_to_update)
      end
    end

    def maintain_elasticsearch_destroy
      ::Elastic::ProcessBookkeepingService.track!(self)
    end

    # Override in child object if there are associations that need to be
    # updated when specific fields are updated
    def associations_needing_elasticsearch_update
      self.class.elastic_index_dependants.map do |dependant|
        association_name = dependant[:association_name]
        on_change = dependant[:on_change]

        next nil unless previous_changes.include?(on_change)

        association_name.to_s
      end.compact.uniq
    end

    class_methods do
      def __elasticsearch__
        @__elasticsearch__ ||= ::Elastic::MultiVersionClassProxy.new(self)
      end

      # Mark a dependant association as needing to be updated when a specific
      # field in this object changes. For example if you want to update
      # project.issues in the index when project.visibility_level is changed
      # then you can declare that as:
      #
      # elastic_index_dependant_association :issues, on_change: :visibility_level
      #
      def elastic_index_dependant_association(association_name, on_change:)
        # Validate these are actually correct associations before sending to
        # Sidekiq to avoid errors occuring when the job is picked up.
        raise "Invalid association to index. \"#{association_name}\" is either not a collection or not an association." unless reflect_on_association(association_name)&.collection?
        raise "Invalid on_change attribute. \"#{on_change}\" is not an attribute of \"#{self}\"" unless has_attribute?(on_change)

        elastic_index_dependants << { association_name: association_name, on_change: on_change }
      end

      def elastic_index_dependants
        @elastic_index_dependants ||= []
      end
    end
  end
end
