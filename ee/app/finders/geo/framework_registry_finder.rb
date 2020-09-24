# frozen_string_literal: true

module Geo
  # Used to provide registry data for GraphQL queries.
  #
  module FrameworkRegistryFinder
    extend ActiveSupport::Concern

    included do
      include Gitlab::Allowable

      delegate :registry_class, to: :replicator_class

      def initialize(current_user, params = {})
        @current_user = current_user
        @params = params
      end

      def execute
        return registry_class.none unless can?(current_user, :read_all_geo)

        registry_entries = init_collection

        registry_entries = by_id(registry_entries)

        registry_entries.ordered
      end

      private

      attr_reader :current_user, :params

      def replicator_class
        Gitlab::Geo::Replicator.for_class_name(self.class.name)
      end

      def init_collection
        registry_class.all
      end

      def by_id(registry_entries)
        return registry_entries if params[:ids].nil?
        return registry_class.none if params[:ids].empty?

        registry_entries.id_in(params[:ids])
      end
    end
  end
end
