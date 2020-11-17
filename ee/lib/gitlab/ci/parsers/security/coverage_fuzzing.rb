# frozen_string_literal: true

module Gitlab
  module Ci
    module Parsers
      module Security
        class CoverageFuzzing < Common
          private

          def create_location(location_data)
            ::Gitlab::Ci::Reports::Security::Locations::CoverageFuzzing.new(
              crash_address: location_data['crash_address'],
              crash_state: location_data['crash_state'],
              crash_type: location_data['crash_type']
            )
          end
        end
      end
    end
  end
end
