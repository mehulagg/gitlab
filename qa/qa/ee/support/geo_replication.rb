# frozen_string_literal: true

module QA
  module EE
    module Support
      module GeoReplication
        module_function

        def wait_for_geo_replication(max_wait: Runtime::Geo.max_file_replication_time)
          QA::Runtime::Logger.debug(%Q[#{self.class.name} - #{caller_locations.first.label}])
          wait_until(max_duration: max_wait ) do
            yield
          end
        end
      end
    end
  end
end
