# frozen_string_literal: true

module EE
  module Users
    module ActivityService
      extend ::Gitlab::Utils::Override

      private

      override :record_activity
      def record_activity
        ::Gitlab::Database::LoadBalancing::Session.without_sticky_writes { super }
      end
    end
  end
end
