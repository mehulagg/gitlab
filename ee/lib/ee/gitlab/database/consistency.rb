# frozen_string_literal: true

module EE
  module Gitlab
    module Database
      module Consistency
        extend ::Gitlab::Utils::Override
        ##
        # In EE we are disabling the database load balancing for calls that
        # require read consistency after recent writes.
        #
        override :with_read_consistency
        def with_read_consistency(&block)
          ::Gitlab::Database::LoadBalancing::Session
            .current.use_primary(&block)
        end
      end
    end
  end
end
