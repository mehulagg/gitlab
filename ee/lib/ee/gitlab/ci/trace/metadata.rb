# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Trace
        module Metadata
          extend ::Gitlab::Utils::Override

          ##
          # In EE we are disabling the database load balancing for requests
          # that attempt to read trace metadata before we actually perform a
          # write.
          #
          # This ensures that we are reading the latest build trace chunks,
          # pending states and checksums.
          #
          override :use_primary
          def use_primary(&block)
            ::Gitlab::Database::LoadBalancing::Session.use_primary(&block)
          end
        end
      end
    end
  end
end
