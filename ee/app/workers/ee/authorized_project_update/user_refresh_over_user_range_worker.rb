# frozen_string_literal: true

module EE
  module AuthorizedProjectUpdate
    module UserRefreshOverUserRangeWorker # rubocop:disable Scalability/IdempotentWorker
      extend ::Gitlab::Utils::Override

      private

      override :use_primary_database
      def use_primary_database
        if ::Gitlab::Database::LoadBalancing.enable?
          ::Gitlab::Database::LoadBalancing::Session.current.use_primary!
        end
      end
    end
  end
end
