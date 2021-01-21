# frozen_string_literal: true

module EE
  class BeforeAllAdapter
    def self.begin_transaction
      TestProf::BeforeAll::Adapters::ActiveRecord.begin_transaction

      ::Geo::BaseRegistry.connection.begin_transaction
    end

    def self.rollback_transaction
      TestProf::BeforeAll::Adapters::ActiveRecord.rollback_transaction

      ::Geo::BaseRegistry.connection.rollback_transaction
    end
  end
end
