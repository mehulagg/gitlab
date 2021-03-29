# frozen_string_literal: true

module EE
  # Intentionally pick a different name, to prevent naming conflicts
  module ApplicationRecordHelpers
    extend ActiveSupport::Concern

    class_methods do
      extend ::Gitlab::Utils::Override

      override :with_fast_read_statement_timeout
      def with_fast_read_statement_timeout(timeout_ms = 5000)
        ::Gitlab::Database::LoadBalancing::Session.current.use_replica_if_possible do
          super
        end
      end
    end
  end
end
