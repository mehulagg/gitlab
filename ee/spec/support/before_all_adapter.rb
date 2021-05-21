# frozen_string_literal: true

module EE
  module BeforeAllAdapter
    extend ActiveSupport::Concern

    class_methods do
      def begin_transaction
        #puts "EE::BeforeAllAdapter.begin_transaction"
        super

        # TODO: CI Vertical: Geo should use many databases of Rails 6
        if ::Gitlab::Geo.geo_database_configured?
          ::Geo::BaseRegistry.connection.begin_transaction(joinable: false)
        end
      end

      def rollback_transaction
        #puts "EE::BeforeAllAdapter.rollback_transaction"
        super

        # TODO: CI Vertical: Geo should use many databases of Rails 6
        if ::Gitlab::Geo.geo_database_configured?
          ::Geo::BaseRegistry.connection.rollback_transaction
        end
      end
    end
  end
end
