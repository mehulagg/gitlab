# frozen_string_literal: true

module EE
  module Gitlab
    module Cleanup
      module OrphanJobArtifactFiles
        extend ::Gitlab::Utils::Override

        attr_accessor :total_geo_registries

        def initialize(**kwargs)
          super

          @total_geo_registries = 0
        end

        override :run!
        def run!
          super

          if ::Gitlab::Geo.secondary?
            log_info("... and delete #{total_geo_registries} Geo registry records.")
          end
        end

        override :update_stats!
        def update_stats!(batch)
          super

          if ::Gitlab::Geo.secondary?
            self.total_geo_registries += batch.geo_registries_count
          end
        end
      end
    end
  end
end
