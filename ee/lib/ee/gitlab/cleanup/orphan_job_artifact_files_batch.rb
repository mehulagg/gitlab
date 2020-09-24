# frozen_string_literal: true

module EE
  module Gitlab
    module Cleanup
      module OrphanJobArtifactFilesBatch
        extend ::Gitlab::Utils::Override

        attr_accessor :geo_registries_count

        override :clean!
        def clean!
          super

          clean_geo_registries! if ::Gitlab::Geo.secondary?
        end

        def clean_geo_registries!
          self.geo_registries_count =
            if dry_run
              lost_and_found_geo_registries.count
            else
              lost_and_found_geo_registries.delete_all
            end
        end

        def lost_and_found_ids
          @lost_and_found_ids ||= lost_and_found.map(&:artifact_id)
        end

        def lost_and_found_geo_registries
          @lost_and_found_geo_registries ||= ::Geo::JobArtifactRegistry.model_id_in(lost_and_found_ids)
        end
      end
    end
  end
end
